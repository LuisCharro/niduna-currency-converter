import '../currency/supported_currencies.dart';
import 'clients/frankfurter_client.dart';
import 'crypto/crypto_usd_history_cache.dart';
import 'crypto/crypto_usd_history_client.dart';
import 'crypto/crypto_usd_history_snapshot.dart';
import 'crypto/historical_rate_composer.dart';
import 'models/rates_snapshot.dart';
import 'rates_client.dart';

class MultiProviderRatesClient implements RatesClient {
  MultiProviderRatesClient({
    required FrankfurterClient fiatClient,
    required CryptoUsdHistoryClient cryptoHistoryClient,
    required CryptoUsdHistoryCache cryptoHistoryCache,
    HistoricalRateComposer? historicalComposer,
  }) : _fiatClient = fiatClient,
       _cryptoHistoryClient = cryptoHistoryClient,
       _cryptoHistoryCache = cryptoHistoryCache,
       _historicalComposer =
           historicalComposer ?? const HistoricalRateComposer();

  final FrankfurterClient _fiatClient;
  final CryptoUsdHistoryClient _cryptoHistoryClient;
  final CryptoUsdHistoryCache _cryptoHistoryCache;
  final HistoricalRateComposer _historicalComposer;

  @override
  Future<RatesSnapshot> fetchLatest(String base) {
    return _fiatClient.fetchLatest(base);
  }

  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    if (isFiatCurrency(base) && isFiatCurrency(quote)) {
      return _fiatClient.fetchHistorical(
        base: base,
        quote: quote,
        from: from,
        to: to,
      );
    }

    if (isCryptoCurrency(base) && isCryptoCurrency(quote)) {
      final baseUsd = await _getCryptoHistory(base, from, to);
      final quoteUsd = await _getCryptoHistory(quote, from, to);
      return _historicalComposer.composeCryptoToCrypto(
        base: base,
        quote: quote,
        baseUsd: baseUsd,
        quoteUsd: quoteUsd,
        from: from,
        to: to,
      );
    }

    if (isFiatCurrency(base) && isCryptoCurrency(quote)) {
      final fiatToUsd = base == 'USD'
          ? _usdIdentityHistory(
              base: base,
              quote: 'USD',
              from: from.subtract(const Duration(days: 7)),
              to: to,
            )
          : await _fiatClient.fetchHistorical(
              base: base,
              quote: 'USD',
              from: from.subtract(const Duration(days: 7)),
              to: to,
            );
      final quoteUsd = await _getCryptoHistory(quote, from, to);
      return _historicalComposer.composeFiatToCrypto(
        base: base,
        quote: quote,
        fiatToUsd: fiatToUsd,
        quoteUsd: quoteUsd,
        from: from,
        to: to,
      );
    }

    if (isCryptoCurrency(base) && isFiatCurrency(quote)) {
      final baseUsd = await _getCryptoHistory(base, from, to);
      final usdToFiat = quote == 'USD'
          ? _usdIdentityHistory(
              base: 'USD',
              quote: quote,
              from: from.subtract(const Duration(days: 7)),
              to: to,
            )
          : await _fiatClient.fetchHistorical(
              base: 'USD',
              quote: quote,
              from: from.subtract(const Duration(days: 7)),
              to: to,
            );
      return _historicalComposer.composeCryptoToFiat(
        base: base,
        quote: quote,
        baseUsd: baseUsd,
        usdToFiat: usdToFiat,
        from: from,
        to: to,
      );
    }

    throw RatesClientException('Unsupported historical pair $base/$quote');
  }

  Future<CryptoUsdHistorySnapshot> _getCryptoHistory(
    String code,
    DateTime from,
    DateTime to,
  ) async {
    final cached = await _cryptoHistoryCache.read(code);
    if (cached != null && cached.covers(from, to)) {
      return cached;
    }

    final fetched = await _cryptoHistoryClient.fetchUsdHistory(
      code: code,
      from: from,
      to: to,
    );
    await _cryptoHistoryCache.write(fetched);
    return (await _cryptoHistoryCache.read(code)) ?? fetched;
  }

  HistoricalSnapshot _usdIdentityHistory({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) {
    final data = <DateTime, double>{};
    var day = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!day.isAfter(end)) {
      data[day] = 1;
      day = day.add(const Duration(days: 1));
    }

    return HistoricalSnapshot(
      base: base,
      quote: quote,
      coveredFrom: DateTime(from.year, from.month, from.day),
      coveredTo: DateTime(to.year, to.month, to.day),
      data: data,
      savedAt: DateTime.now(),
    );
  }
}
