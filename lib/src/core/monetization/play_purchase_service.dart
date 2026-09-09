import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'purchase_service.dart';

/// Real Google Play Billing implementation of [PurchaseService].
///
/// All three products are non-consumable lifetime unlocks. Purchase and
/// restore results arrive asynchronously on the platform purchase stream;
/// entitlement persistence stays in [MonetizationController], which receives
/// granted products through [onEntitlement].
class PlayPurchaseService implements PurchaseService {
  PlayPurchaseService({void Function(ProductType product)? onEntitlement})
    : _onEntitlement = onEntitlement {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handleUpdates,
    );
  }

  static const Map<ProductType, String> productIds = {
    ProductType.removeAds: 'remove_ads_lifetime',
    ProductType.chartsPro: 'charts_pro_lifetime',
    ProductType.favoritesPro: 'favorites_pro_lifetime',
  };

  final void Function(ProductType product)? _onEntitlement;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Map<String, Completer<bool>> _pendingByProductId = {};

  @override
  Future<bool> purchase(ProductType product) async {
    final productId = productIds[product];
    if (productId == null) return false;

    final store = InAppPurchase.instance;
    if (!await store.isAvailable()) return false;

    final response = await store.queryProductDetails({productId});
    if (response.error != null) return false;
    if (response.productDetails.isEmpty) return false;

    final completer = Completer<bool>();
    _pendingByProductId[productId] = completer;

    final started = await store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: response.productDetails.first),
    );
    if (!started) {
      _pendingByProductId.remove(productId);
      return false;
    }
    return completer.future;
  }

  @override
  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  void _handleUpdates(List<PurchaseDetails> updates) {
    for (final details in updates) {
      switch (details.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _grant(details);
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _settle(details.productID, false);
        case PurchaseStatus.pending:
          break;
      }
      if (details.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(details);
      }
    }
  }

  void _grant(PurchaseDetails details) {
    final product = _productFor(details.productID);
    if (product != null) _onEntitlement?.call(product);
    _settle(details.productID, true);
  }

  void _settle(String productId, bool success) {
    final pending = _pendingByProductId.remove(productId);
    if (pending != null && !pending.isCompleted) pending.complete(success);
  }

  ProductType? _productFor(String productId) {
    for (final entry in productIds.entries) {
      if (entry.value == productId) return entry.key;
    }
    return null;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
