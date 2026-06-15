import 'dart:async';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/rates/crypto/crypto_usd_price_cache.dart';
import '../../../core/rates/crypto/crypto_usd_price_client.dart';
import '../../../core/rates/crypto/crypto_usd_price_snapshot.dart';
import '../../../core/rates/crypto/rate_normalizer.dart';
import '../../../core/rates/rate_refresh_policy.dart';
import '../domain/latest_rates_snapshot.dart';
import 'latest_rates_cache.dart';
import 'latest_rates_client.dart';
import 'latest_rates_repository.dart';

class MultiProviderLatestRatesRepository implements ConvertRatesRepository {
  MultiProviderLatestRatesRepository({
    required LatestRatesClient fiatClient,
    required LatestRatesCache latestCache,
    required CryptoUsdPriceCache cryptoCache,
    required CryptoUsdPriceClient cryptoClient,
    RateNormalizer normalizer = const RateNormalizer(),
  }) : _fiatClient = fiatClient,
       _latestCache = latestCache,
       _cryptoCache = cryptoCache,
       _cryptoClient = cryptoClient,
       _normalizer = normalizer;

  final LatestRatesClient _fiatClient;
  final LatestRatesCache _latestCache;
  final CryptoUsdPriceCache _cryptoCache;
  final CryptoUsdPriceClient _cryptoClient;
  final RateNormalizer _normalizer;
  final Map<String, Future<LatestRatesSnapshot>> _inFlightByBase =
      <String, Future<LatestRatesSnapshot>>{};

  @override
  Future<LatestRatesSnapshot?> readCached(String base) async {
    final cached = await _latestCache.read(base);
    if (cached == null || isCryptoCurrency(base)) {
      return cached;
    }

    if (_hasAllCryptoRates(cached)) {
      return cached;
    }

    final cryptoSnapshot = await _readFreshCryptoCache();
    if (cryptoSnapshot == null) {
      return cached;
    }

    return LatestRatesSnapshot(
      base: cached.base,
      date: cached.date,
      savedAt: cached.savedAt,
      rates: Map<String, double>.from(cached.rates)
        ..addAll(
          _normalizer.normalizeFiatBase(
            base: base,
            fiatRates: cached.rates,
            cryptoUsdPrices: cryptoSnapshot.pricesUsd,
          )..removeWhere((code, _) => isFiatCurrency(code)),
        ),
    );
  }

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async {
    if (isCryptoCurrency(base)) {
      throw StateError('Crypto base is not supported yet');
    }

    final existing = _inFlightByBase[base];
    if (existing != null) {
      return existing;
    }

    final request = _fetchLatestUnshared(base);
    _inFlightByBase[base] = request;
    try {
      return await request;
    } finally {
      _inFlightByBase.remove(base);
    }
  }

  Future<LatestRatesSnapshot> _fetchLatestUnshared(String base) async {
    final fiatSnapshot = await _fiatClient.fetchLatest(base);
    final cachedSnapshot = await _latestCache.read(base);
    final cryptoSnapshot = await _readFreshCryptoCache() ?? await _fetchCryptoSafe();

    final mergedRates = Map<String, double>.from(fiatSnapshot.rates);
    if (cryptoSnapshot != null) {
      mergedRates.addAll(
        _normalizer.normalizeFiatBase(
          base: base,
          fiatRates: fiatSnapshot.rates,
          cryptoUsdPrices: cryptoSnapshot.pricesUsd,
        )..removeWhere((code, _) => isFiatCurrency(code)),
      );
    } else if (cachedSnapshot != null) {
      for (final currency in supportedCryptoCurrencies) {
        final cachedRate = cachedSnapshot.rates[currency.code];
        if (cachedRate != null) {
          mergedRates[currency.code] = cachedRate;
        }
      }
    }

    final snapshot = LatestRatesSnapshot(
      base: fiatSnapshot.base,
      date: fiatSnapshot.date,
      savedAt: fiatSnapshot.savedAt,
      rates: mergedRates,
    );
    await _latestCache.write(snapshot);
    return snapshot;
  }

  Future<CryptoUsdPriceSnapshot?> _readFreshCryptoCache() async {
    final cached = await _cryptoCache.read();
    if (cached == null) return null;
    if (RateRefreshPolicy.isFreshForToday(cached.savedAt)) {
      return cached;
    }
    return null;
  }

  Future<CryptoUsdPriceSnapshot?> _fetchCryptoSafe() async {
    try {
      final snapshot = await _cryptoClient.fetchUsdPrices().timeout(
        const Duration(seconds: 10),
      );
      await _cryptoCache.write(snapshot);
      return snapshot;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) => _fiatClient.fetchPreviousRates(base, referenceDate: referenceDate);

  bool _hasAllCryptoRates(LatestRatesSnapshot snapshot) {
    for (final currency in supportedCryptoCurrencies) {
      if (!snapshot.rates.containsKey(currency.code)) {
        return false;
      }
    }
    return true;
  }
}
