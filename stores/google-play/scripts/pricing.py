#!/usr/bin/env python3
"""Read the Play one-time catalog or plan prices offline. Never writes to Play."""
from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import sys
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
from pathlib import Path

from google_play import (build_service, emit_result, load_config, play_operation_lock,
                         safe_api_error_message)


def read_catalog() -> dict:
    package = load_config()['packageName']
    service = build_service()
    products = []
    with play_operation_lock(package):
        token = None
        seen_tokens = set()
        while True:
            arguments = {'packageName': package, 'pageSize': 100}
            if token:
                arguments['pageToken'] = token
            response = service.monetization().onetimeproducts().list(**arguments).execute()
            products.extend(response.get('oneTimeProducts', []))
            token = response.get('nextPageToken')
            if not token:
                break
            if token in seen_tokens:
                raise ValueError('Repeated catalog pagination token; read aborted.')
            seen_tokens.add(token)
    return {'schemaVersion': 1, 'packageName': package,
            'observedAt': datetime.now(timezone.utc).isoformat(),
            'api': 'monetization.onetimeproducts', 'oneTimeProducts': products}


def amount(money: dict) -> Decimal:
    value = Decimal(money.get('units', '0')) + Decimal(money.get('nanos', 0)) / Decimal(10**9)
    if not value.is_finite() or value <= 0:
        raise ValueError('Expected a positive finite catalog price.')
    return value


def proposed_amount(value: str) -> Decimal:
    if not isinstance(value, str):
        raise ValueError('Policy prices must be decimal strings, not floats.')
    try:
        result = Decimal(value)
    except InvalidOperation as error:
        raise ValueError('Invalid policy amount.') from error
    if not result.is_finite() or result <= 0 or result.as_tuple().exponent < -9:
        raise ValueError('Policy price must be positive with at most nine decimals.')
    return result


def make_plan(catalog: dict, policy: dict, snapshot_hash: str) -> dict:
    package = load_config()['packageName']
    if catalog.get('packageName') != package or policy.get('packageName') != package:
        raise ValueError('Catalog/policy package does not match configured app.')
    if catalog.get('api') != 'monetization.onetimeproducts':
        raise ValueError('Expected the modern one-time product catalog.')
    products = {p['productId']: p for p in catalog['oneTimeProducts']}
    if len(products) != len(catalog['oneTimeProducts']):
        raise ValueError('Duplicate product ID in catalog.')
    desired = policy['products']
    if set(desired) != set(products):
        raise ValueError('Policy must explicitly cover every live product; review catalog drift.')
    rows = []
    for product_id, rules in sorted(desired.items()):
        product = products[product_id]
        options = product.get('purchaseOptions', [])
        if len(options) != 1 or 'buyOption' not in options[0]:
            raise ValueError('Review required: expected exactly one buy option per product.')
        option = options[0]
        if option['purchaseOptionId'] != rules['purchaseOptionId'] or option.get('state') != 'ACTIVE':
            raise ValueError('Purchase option identity/state changed; review before planning.')
        seen = set()
        for region in option.get('regionalPricingAndAvailabilityConfigs', []):
            code = region['regionCode']
            if code in seen:
                raise ValueError('Duplicate region in catalog.')
            seen.add(code)
            currency = region['price']['currencyCode']
            current = amount(region['price'])
            override = rules.get('regionOverrides', {}).get(code)
            if override:
                if override['currencyCode'] != currency:
                    raise ValueError('Regional override cannot change the region currency.')
                target = proposed_amount(override['amount'])
                reason = 'region override'
            elif currency in rules.get('currencyOverrides', {}):
                target = proposed_amount(rules['currencyOverrides'][currency])
                reason = 'currency override'
            else:
                target = current
                reason = 'retain current; pending local strategy'
            rows.append({'productId': product_id, 'purchaseOptionId': option['purchaseOptionId'],
                         'regionCode': code, 'currencyCode': currency,
                         'current': format(current, 'f'), 'proposed': format(target, 'f'),
                         'changePercent': format(((target/current-1)*100).quantize(Decimal('0.01')), 'f'),
                         'changed': current != target, 'availability': region.get('availability'),
                         'priceValidation': 'not checked against Google ranges/tax/currency precision',
                         'reason': reason})
        missing = set(rules.get('regionOverrides', {})) - seen
        if missing:
            raise ValueError(f'Regional overrides absent from catalog: {sorted(missing)}')
        configured = set(rules.get('currencyOverrides', {}))
        present = {r['price']['currencyCode'] for r in option.get('regionalPricingAndAvailabilityConfigs', [])}
        if configured - present:
            raise ValueError('A currency override matches no live region.')
    return {'schemaVersion': 1, 'packageName': package, 'policyStatus': policy['status'],
            'generatedAt': datetime.now(timezone.utc).isoformat(),
            'catalogObservedAt': catalog.get('observedAt'), 'snapshotSha256': snapshot_hash,
            'summary': {'priceRows': len(rows), 'changedPriceRows': sum(r['changed'] for r in rows),
                        'changedRegions': len({r['regionCode'] for r in rows if r['changed']})},
            'writesToPlay': False, 'validatedByGoogle': False,
            'limitations': ['Offline proposal, not a Google validation or update payload.',
                            'No price-range or tax validation; review final checkout by region.',
                            'No availability, future-region, offer, tax or entitlement changes.',
                            'A later writer needs fresh catalog, approved diff and post-write verification.'],
            'rows': rows}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    live = sub.add_parser('catalog', help='Authenticated read; no edit or catalog mutation.')
    live.add_argument('--output', type=Path, required=True)
    plan = sub.add_parser('plan', help='Offline price comparison; no credentials needed.')
    plan.add_argument('--catalog', type=Path, required=True)
    plan.add_argument('--policy', type=Path, required=True)
    plan.add_argument('--output', type=Path, required=True)
    plan.add_argument('--csv-output', type=Path)
    args = parser.parse_args()
    if args.output.exists() or (getattr(args, 'csv_output', None) and args.csv_output.exists()):
        parser.error('Output exists. Use new receipt paths; never overwrite snapshots/plans.')
    if not args.output.parent.is_dir() or (getattr(args, 'csv_output', None) and not args.csv_output.parent.is_dir()):
        parser.error('Create the output directories first.')
    try:
        if args.command == 'catalog':
            result = read_catalog()
        else:
            raw = args.catalog.read_bytes()
            result = make_plan(json.loads(raw), json.loads(args.policy.read_text()),
                               hashlib.sha256(raw).hexdigest())
            if args.csv_output:
                stream = io.StringIO(newline='')
                rows = result['rows']
                writer = csv.DictWriter(stream, fieldnames=list(rows[0]) if rows else [])
                writer.writeheader()
                writer.writerows(rows)
                with args.csv_output.open('x', newline='', encoding='utf-8') as output:
                    output.write(stream.getvalue())
        emit_result(result, args.output)
        return 0
    except Exception as error:
        # Do not include HTTP request/credential objects in error output.
        detail = str(error) if isinstance(error, (ValueError, OSError, KeyError)) else safe_api_error_message(error)
        print(f'Pricing failed ({type(error).__name__}): {detail}. No Play write was attempted.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
