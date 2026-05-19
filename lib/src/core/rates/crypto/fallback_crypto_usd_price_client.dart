import 'crypto_usd_price_client.dart';
import 'crypto_usd_price_snapshot.dart';

class FallbackCryptoUsdPriceClient implements CryptoUsdPriceClient {
  const FallbackCryptoUsdPriceClient({
    required CryptoUsdPriceClient primary,
    required CryptoUsdPriceClient fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final CryptoUsdPriceClient _primary;
  final CryptoUsdPriceClient _fallback;

  @override
  Future<CryptoUsdPriceSnapshot> fetchUsdPrices() async {
    try {
      return await _primary.fetchUsdPrices();
    } catch (_) {
      return _fallback.fetchUsdPrices();
    }
  }
}
