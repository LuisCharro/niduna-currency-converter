"""Guarded price-only updates using the modern one-time product API."""
from __future__ import annotations

import copy
import hashlib
import json
import os
from datetime import datetime, timezone
from decimal import Decimal
from pathlib import Path

from google_play import build_service, load_config, play_operation_lock, safe_api_error_message
from pricing import amount, make_plan, read_catalog_unlocked


def save(path: Path, value: dict) -> None:
    with path.open('x', encoding='utf-8') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')
        stream.flush()
        os.fsync(stream.fileno())


def normalized(value):
    """Ignore ordering/default-zero money encoding, but preserve every field/value."""
    if isinstance(value, dict):
        if 'currencyCode' in value and ('units' in value or 'nanos' in value):
            return {'currencyCode': value['currencyCode'], 'amount': format(amount(value).normalize(), 'f')}
        return {key: normalized(item) for key, item in value.items()}
    if isinstance(value, list):
        return sorted((normalized(item) for item in value), key=lambda item: json.dumps(item, sort_keys=True))
    return value


def money(currency: str, price: str) -> dict:
    value = Decimal(price)
    units = int(value)
    return {'currencyCode': currency, 'units': str(units),
            'nanos': int((value-units)*10**9)}


def expected_products(catalog: dict, plan: dict) -> dict:
    products = {p['productId']: copy.deepcopy(p) for p in catalog['oneTimeProducts']}
    for row in plan['rows']:
        if not row['changed']:
            continue
        product = products[row['productId']]
        option = next(o for o in product['purchaseOptions'] if o['purchaseOptionId'] == row['purchaseOptionId'])
        region = next(r for r in option['regionalPricingAndAvailabilityConfigs'] if r['regionCode'] == row['regionCode'])
        region['price'] = money(row['currencyCode'], row['proposed'])
    return products


def require_no_offers(service, package: str, catalog: dict) -> None:
    # Base price updates can affect linked offers; do not silently expand scope.
    for product in catalog['oneTimeProducts']:
        for option in product['purchaseOptions']:
            response = service.monetization().onetimeproducts().purchaseOptions().offers().list(
                packageName=package, productId=product['productId'],
                purchaseOptionId=option['purchaseOptionId'], pageSize=100).execute()
            if response.get('oneTimeProductOffers') or response.get('nextPageToken'):
                raise ValueError('Linked offers require a separate pricing review.')


def apply_prices(args) -> dict:
    package = load_config()['packageName']
    if args.confirm_package != package:
        raise ValueError('Explicit package confirmation does not match app.')
    raw = args.catalog.read_bytes()
    catalog, policy = json.loads(raw), json.loads(args.policy.read_text())
    approved = json.loads(args.plan.read_text())
    if policy.get('status') != 'approved-for-application':
        raise ValueError('Policy is not approved for application.')
    plan = make_plan(catalog, policy, hashlib.sha256(raw).hexdigest())
    for field in ('packageName', 'snapshotSha256', 'policySha256', 'rows', 'summary'):
        if approved.get(field) != plan[field]:
            raise ValueError(f'Approved plan binding mismatch: {field}')
    expected = expected_products(catalog, plan)
    service = build_service()
    # Existing/nonempty directories are refused; preserve each attempt as a new receipt set.
    args.receipt_dir.mkdir(parents=False, exist_ok=False)
    directory = args.receipt_dir
    changed = sorted({r['productId'] for r in plan['rows'] if r['changed']})
    attempted = []
    with play_operation_lock(package):
        try:
            fresh = read_catalog_unlocked(service, package)
            save(directory/'before.json', fresh)
            if normalized(fresh['oneTimeProducts']) != normalized(catalog['oneTimeProducts']):
                raise ValueError('Live catalog changed since planning; prepare and review a new plan.')
            require_no_offers(service, package, fresh)
            save(directory/'plan.json', approved)
            save(directory/'policy.json', policy)
            for product_id in changed:
                original = next(p for p in fresh['oneTimeProducts'] if p['productId'] == product_id)
                # Recheck each product immediately before its update, including unrelated fields.
                current = service.monetization().onetimeproducts().get(
                    packageName=package, productId=product_id).execute()
                if normalized(current) != normalized(original):
                    raise ValueError('Product changed during operation; stopped before next write.')
                options = copy.deepcopy(expected[product_id]['purchaseOptions'])
                for option in options:
                    option.pop('state', None)  # Output-only; state is verified after writing.
                body = {'packageName': package, 'productId': product_id, 'purchaseOptions': options}
                save(directory/f'request-{product_id}.json', body)
                attempted.append(product_id)
                save(directory/f'attempt-{product_id}.json', {'at': datetime.now(timezone.utc).isoformat()})
                response = service.monetization().onetimeproducts().patch(
                    packageName=package, productId=product_id, body=body,
                    updateMask='purchaseOptions', allowMissing=False,
                    **{'regionsVersion.version': original['regionsVersion']['version']}
                ).execute(num_retries=0)
                save(directory/f'response-{product_id}.json', response)
                actual = service.monetization().onetimeproducts().get(
                    packageName=package, productId=product_id).execute()
                save(directory/f'verified-{product_id}.json', actual)
                if normalized(actual) != normalized(expected[product_id]):
                    raise ValueError('Readback differs from intended prices or preserved fields; stopped.')
            after = read_catalog_unlocked(service, package)
            save(directory/'after.json', after)
            if normalized(after['oneTimeProducts']) != normalized(list(expected.values())):
                raise ValueError('Full catalog verification differs; reconcile live state.')
            result = {'packageName': package, 'verified': True, 'summary': plan['summary'],
                      'updatedProducts': changed, 'policySha256': plan['policySha256'],
                      'receiptDirectory': str(directory.resolve()),
                      'scope': 'Prices only. No release, distribution, tax, offer or availability update.'}
            save(directory/'result.json', result)
            return result
        except Exception as error:
            detail = str(error) if isinstance(error, (ValueError, OSError, KeyError)) else safe_api_error_message(error)
            save(directory/'failure.json', {'errorType': type(error).__name__, 'detail': detail,
                                           'attemptedProducts': attempted, 'automaticRetry': False})
            raise RuntimeError(f'{type(error).__name__}: {detail}; attempted products: {attempted}') from None
