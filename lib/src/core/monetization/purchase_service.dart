enum ProductType {
  removeAds,
  chartsPro,
  subscription,
}

abstract class PurchaseService {
  Future<bool> purchase(ProductType product);
}
