import 'purchase_service.dart';

/// Optional store capability for prices formatted in the user's store locale.
abstract class ProductPriceCatalog {
  Future<Map<ProductType, String>> fetchLocalizedPrices();
}
