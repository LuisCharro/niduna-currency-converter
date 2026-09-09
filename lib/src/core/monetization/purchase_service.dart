enum ProductType { removeAds, chartsPro, favoritesPro, subscription }

abstract class PurchaseService {
  Future<bool> purchase(ProductType product);

  /// Asks the store to re-deliver past purchases; results arrive through
  /// the service's own entitlement callback where applicable.
  Future<void> restore();
}
