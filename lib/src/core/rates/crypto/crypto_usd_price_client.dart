import 'crypto_usd_price_snapshot.dart';

abstract class CryptoUsdPriceClient {
  Future<CryptoUsdPriceSnapshot> fetchUsdPrices();
}

class CryptoUsdPriceException implements Exception {
  const CryptoUsdPriceException(this.message);

  final String message;

  @override
  String toString() => message;
}
