import 'crypto/coinpaprika_crypto_usd_history_client.dart';
import 'crypto/coingecko_crypto_usd_history_client.dart';
import 'crypto/crypto_usd_history_client.dart';
import 'crypto/fawazahmed_crypto_usd_history_client.dart';
import 'crypto/coinpaprika_crypto_usd_price_client.dart';
import 'crypto/crypto_usd_price_client.dart';
import 'crypto/fallback_crypto_usd_price_client.dart';
import 'crypto/fawazahmed_crypto_usd_price_client.dart';
import 'crypto/unsupported_crypto_usd_history_client.dart';
import 'provider_config.dart';

class ProviderFactory {
  static CryptoUsdPriceClient createCryptoLatestClient() {
    final providers = ProviderConfig.cryptoLatestOrder;
    var client = _latestClientFor(providers.last);

    for (final provider in providers.reversed.skip(1)) {
      client = FallbackCryptoUsdPriceClient(
        primary: _latestClientFor(provider),
        fallback: client,
      );
    }

    return client;
  }

  static CryptoUsdHistoryClient createCryptoHistoryClient() {
    switch (ProviderConfig.cryptoHistoryProvider) {
      case CryptoHistoryProvider.coinPaprika:
        return CoinPaprikaCryptoUsdHistoryClient();
      case CryptoHistoryProvider.fawazahmed0:
        return FawazahmedCryptoUsdHistoryClient();
      case CryptoHistoryProvider.coingecko:
        return CoingeckoCryptoUsdHistoryClient();
      case CryptoHistoryProvider.none:
        return const UnsupportedCryptoUsdHistoryClient(
          'Crypto charts are not available in this release.',
        );
    }
  }

  static CryptoUsdPriceClient _latestClientFor(CryptoLatestProvider provider) {
    switch (provider) {
      case CryptoLatestProvider.coinPaprika:
        return CoinPaprikaCryptoUsdPriceClient();
      case CryptoLatestProvider.fawazahmed0:
        return FawazahmedCryptoUsdPriceClient();
    }
  }
}