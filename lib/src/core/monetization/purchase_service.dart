enum ProductType { removeAds, chartsPro, favoritesPro, subscription }

abstract class PurchaseService {
  Future<bool> purchase(ProductType product);
}
