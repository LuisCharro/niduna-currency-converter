import 'package:currency_converter/src/core/currency/supported_currencies.dart';
import 'package:currency_converter/src/core/preferences/app_preferences.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_price_cache.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_price_client.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_price_snapshot.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_cache.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_client.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/data/multi_provider_latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/convert_quote_builder.dart';
import 'package:currency_converter/src/features/convert/domain/convert_state.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'currencyByCode resolves crypto currencies without changing fiat list',
    () {
      expect(currencyByCode('BTC').name, 'Bitcoin');
      expect(currencyByCode('ETH').name, 'Ethereum');
      expect(
        supportedCurrencies.map((currency) => currency.code),
        isNot(contains('BTC')),
      );
    },
  );

  test('buildQuotes keeps BTC precision in quote amounts and rate lines', () {
    final quotes = buildQuotes(
      snapshot: LatestRatesSnapshot(
        base: 'EUR',
        date: DateTime(2026, 5, 19),
        savedAt: DateTime(2026, 5, 19, 10),
        rates: const <String, double>{'BTC': 0.00001508},
      ),
      amount: 100,
      decimalPlaces: 2,
      quoteCodes: const <String>['BTC'],
    );

    expect(quotes.single.amount, '0.00150800');
    expect(quotes.single.rateLine, '1 EUR = 0.00001508 BTC');
  });

  test('clearAllCaches removes latest and crypto cache keys', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'latest_rates_USD': '{"base":"USD"}',
      'crypto_usd_prices_v1': '{"provider":"coinpaprika"}',
      'crypto_usd_history_BTC': '{"code":"BTC"}',
      'historical_rates_USD_EUR': '{"base":"USD"}',
    });
    final prefs = await SharedPreferences.getInstance();
    final preferences = AppPreferences(prefs);

    await preferences.clearAllCaches();

    expect(prefs.getString('latest_rates_USD'), isNull);
    expect(prefs.getString('crypto_usd_prices_v1'), isNull);
    expect(prefs.getString('crypto_usd_history_BTC'), isNull);
    expect(prefs.getString('historical_rates_USD_EUR'), isNull);
  });

  test(
    'controller load skips refresh when refreshOnOpen is false and cache is complete',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'pref_refresh_on_open': false,
      });
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);
      final repository = _CountingRatesRepository(
        cached: LatestRatesSnapshot(
          base: 'USD',
          date: DateTime(2026, 5, 19),
          savedAt: DateTime.now(),
          rates: const <String, double>{
            'EUR': 0.92,
            'BTC': 0.000013,
            'ETH': 0.0004,
          },
        ),
      );

      final controller = ConvertController(
        repository: repository,
        preferences: preferences,
        selectedCodes: const <String>['EUR'],
      );

      await controller.load();

      expect(repository.fetchCalls, 0);
      expect(controller.state.status, isNot(equals(ConvertStatus.noCache)));
    },
  );

  test('controller load refreshes when cached snapshot is missing crypto rates', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'pref_refresh_on_open': false,
    });
    final prefs = await SharedPreferences.getInstance();
    final preferences = AppPreferences(prefs);
    final repository = _CountingRatesRepository(
      cached: LatestRatesSnapshot(
        base: 'USD',
        date: DateTime(2026, 5, 19),
        savedAt: DateTime.now(),
        rates: const <String, double>{'EUR': 0.92},
      ),
    );

    final controller = ConvertController(
      repository: repository,
      preferences: preferences,
      selectedCodes: const <String>['EUR', 'BTC'],
    );

    await controller.load();

    expect(repository.fetchCalls, 1);
  });

  test(
    'multi-provider repository merges BTC and ETH into fiat snapshot',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = MultiProviderLatestRatesRepository(
        fiatClient: _FakeLatestRatesClient(
          LatestRatesSnapshot(
            base: 'EUR',
            date: DateTime(2026, 5, 19),
            savedAt: DateTime(2026, 5, 19, 10),
            rates: const <String, double>{'USD': 1.2, 'GBP': 0.8},
          ),
        ),
        latestCache: LatestRatesCache(prefs),
        cryptoCache: CryptoUsdPriceCache(prefs),
        cryptoClient: _FakeCryptoUsdPriceClient(
          CryptoUsdPriceSnapshot(
            provider: 'test',
            savedAt: _today,
            pricesUsd: <String, double>{'BTC': 60000, 'ETH': 3000},
          ),
        ),
      );

      final snapshot = await repository.fetchLatest('EUR');

      expect(snapshot.rates['GBP'], 0.8);
      expect(snapshot.rates['BTC'], closeTo(0.00002, 0.000000001));
      expect(snapshot.rates['ETH'], closeTo(0.0004, 0.000000001));
    },
  );

  test(
    'multi-provider repository preserves cached crypto when refresh fails',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final latestCache = LatestRatesCache(prefs);
      await latestCache.write(
        LatestRatesSnapshot(
          base: 'USD',
          date: DateTime(2026, 5, 18),
          savedAt: DateTime(2026, 5, 18, 10),
          rates: const <String, double>{'EUR': 0.9, 'BTC': 0.000013},
        ),
      );

      final repository = MultiProviderLatestRatesRepository(
        fiatClient: _FakeLatestRatesClient(
          LatestRatesSnapshot(
            base: 'USD',
            date: DateTime(2026, 5, 19),
            savedAt: DateTime(2026, 5, 19, 10),
            rates: const <String, double>{'EUR': 0.92},
          ),
        ),
        latestCache: latestCache,
        cryptoCache: CryptoUsdPriceCache(prefs),
        cryptoClient: _FailingCryptoUsdPriceClient(),
      );

      final snapshot = await repository.fetchLatest('USD');

      expect(snapshot.rates['EUR'], 0.92);
      expect(snapshot.rates['BTC'], 0.000013);
    },
  );

  test('multi-provider repository readCached backfills crypto from fresh crypto cache', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final latestCache = LatestRatesCache(prefs);
    final cryptoCache = CryptoUsdPriceCache(prefs);
    await latestCache.write(
      LatestRatesSnapshot(
        base: 'EUR',
        date: DateTime(2026, 5, 19),
        savedAt: DateTime(2026, 5, 19, 10),
        rates: const <String, double>{'USD': 1.2, 'GBP': 0.8},
      ),
    );
    await cryptoCache.write(
      CryptoUsdPriceSnapshot(
        provider: 'test',
        savedAt: _today,
        pricesUsd: <String, double>{'BTC': 60000, 'ETH': 3000},
      ),
    );

    final repository = MultiProviderLatestRatesRepository(
      fiatClient: _FakeLatestRatesClient(
        LatestRatesSnapshot(
          base: 'EUR',
          date: DateTime(2026, 5, 19),
          savedAt: DateTime(2026, 5, 19, 10),
          rates: const <String, double>{'USD': 1.2, 'GBP': 0.8},
        ),
      ),
      latestCache: latestCache,
      cryptoCache: cryptoCache,
      cryptoClient: _FailingCryptoUsdPriceClient(),
    );

    final cached = await repository.readCached('EUR');

    expect(cached?.rates['BTC'], closeTo(0.00002, 0.000000001));
    expect(cached?.rates['ETH'], closeTo(0.0004, 0.000000001));
  });
}

final DateTime _today = DateTime.now();

class _FakeLatestRatesClient implements LatestRatesClient {
  const _FakeLatestRatesClient(this.snapshot);

  final LatestRatesSnapshot snapshot;

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async => snapshot;

  @override
  Future<Map<String, double>?> fetchYesterdayRates(String base) async => null;
}

class _FakeCryptoUsdPriceClient implements CryptoUsdPriceClient {
  const _FakeCryptoUsdPriceClient(this.snapshot);

  final CryptoUsdPriceSnapshot snapshot;

  @override
  Future<CryptoUsdPriceSnapshot> fetchUsdPrices() async => snapshot;
}

class _FailingCryptoUsdPriceClient implements CryptoUsdPriceClient {
  @override
  Future<CryptoUsdPriceSnapshot> fetchUsdPrices() async {
    throw const CryptoUsdPriceException('offline');
  }
}

class _CountingRatesRepository implements ConvertRatesRepository {
  _CountingRatesRepository({this.cached});

  final LatestRatesSnapshot? cached;
  int fetchCalls = 0;

  @override
  Future<LatestRatesSnapshot?> readCached(String base) async => cached;

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async {
    fetchCalls += 1;
    throw StateError('should not fetch');
  }

  @override
  Future<Map<String, double>?> fetchYesterdayRates(String base) async => null;
}
