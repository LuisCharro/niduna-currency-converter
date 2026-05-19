import 'package:currency_converter/src/core/rates/clients/frankfurter_client.dart';
import 'package:currency_converter/src/core/rates/crypto/coinpaprika_crypto_usd_history_client.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_history_cache.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_history_client.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_history_snapshot.dart';
import 'package:currency_converter/src/core/rates/models/rates_snapshot.dart';
import 'package:currency_converter/src/core/rates/multi_provider_rates_client.dart';
import 'package:currency_converter/src/core/rates/rates_cache.dart';
import 'package:currency_converter/src/core/rates/rates_client.dart';
import 'package:currency_converter/src/core/rates/rates_service.dart';
import 'package:currency_converter/src/features/charts/domain/chart_range.dart';
import 'package:currency_converter/src/features/charts/presentation/charts_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('coinpaprika history client parses daily BTC USD history', () async {
    final client = CoinPaprikaCryptoUsdHistoryClient(
      client: _StaticHttpClient(
        '[{"timestamp":"2026-05-12T00:00:00Z","price":80793.61}]',
      ),
    );

    final snapshot = await client.fetchUsdHistory(
      code: 'BTC',
      from: DateTime(2026, 5, 12),
      to: DateTime(2026, 5, 12),
    );

    expect(snapshot.code, 'BTC');
    expect(snapshot.pricesUsd[DateTime(2026, 5, 12)], 80793.61);
  });

  test('multi-provider client composes BTC to ETH history', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final client = MultiProviderRatesClient(
      fiatClient: _FakeFrankfurterClient(),
      cryptoHistoryClient: _FakeCryptoUsdHistoryClient(
        snapshots: <String, CryptoUsdHistorySnapshot>{
          'BTC': _cryptoHistory('BTC', <DateTime, double>{
            DateTime(2026, 5, 12): 80000,
          }),
          'ETH': _cryptoHistory('ETH', <DateTime, double>{
            DateTime(2026, 5, 12): 2000,
          }),
        },
      ),
      cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
    );

    final result = await client.fetchHistorical(
      base: 'BTC',
      quote: 'ETH',
      from: DateTime(2026, 5, 12),
      to: DateTime(2026, 5, 12),
    );

    expect(result.data[DateTime(2026, 5, 12)], 40);
  });

  test(
    'multi-provider client carries forward fiat close for EUR to BTC',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final client = MultiProviderRatesClient(
        fiatClient: _FakeFrankfurterClient(
          historical: HistoricalSnapshot(
            base: 'EUR',
            quote: 'USD',
            coveredFrom: DateTime(2026, 5, 15),
            coveredTo: DateTime(2026, 5, 16),
            data: <DateTime, double>{DateTime(2026, 5, 15): 1.2},
            savedAt: DateTime.now(),
          ),
        ),
        cryptoHistoryClient: _FakeCryptoUsdHistoryClient(
          snapshots: <String, CryptoUsdHistorySnapshot>{
            'BTC': _cryptoHistory('BTC', <DateTime, double>{
              DateTime(2026, 5, 16): 60000,
            }),
          },
        ),
        cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
      );

      final result = await client.fetchHistorical(
        base: 'EUR',
        quote: 'BTC',
        from: DateTime(2026, 5, 16),
        to: DateTime(2026, 5, 16),
      );

      expect(result.data[DateTime(2026, 5, 16)], closeTo(0.00002, 0.000000001));
    },
  );

  test('multi-provider client handles USD to BTC without Frankfurter USD/USD', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final client = MultiProviderRatesClient(
      fiatClient: _ThrowingUsdUsdFrankfurterClient(),
      cryptoHistoryClient: _FakeCryptoUsdHistoryClient(
        snapshots: <String, CryptoUsdHistorySnapshot>{
          'BTC': _cryptoHistory('BTC', <DateTime, double>{
            DateTime(2026, 5, 16): 50000,
          }),
        },
      ),
      cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
    );

    final result = await client.fetchHistorical(
      base: 'USD',
      quote: 'BTC',
      from: DateTime(2026, 5, 16),
      to: DateTime(2026, 5, 16),
    );

    expect(result.data[DateTime(2026, 5, 16)], closeTo(0.00002, 0.000000001));
  });

  test('multi-provider client handles BTC to USD without Frankfurter USD/USD', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final client = MultiProviderRatesClient(
      fiatClient: _ThrowingUsdUsdFrankfurterClient(),
      cryptoHistoryClient: _FakeCryptoUsdHistoryClient(
        snapshots: <String, CryptoUsdHistorySnapshot>{
          'BTC': _cryptoHistory('BTC', <DateTime, double>{
            DateTime(2026, 5, 16): 50000,
          }),
        },
      ),
      cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
    );

    final result = await client.fetchHistorical(
      base: 'BTC',
      quote: 'USD',
      from: DateTime(2026, 5, 16),
      to: DateTime(2026, 5, 16),
    );

    expect(result.data[DateTime(2026, 5, 16)], 50000);
  });

  test('charts controller downgrades 2Y to 1Y for crypto pair', () {
    final controller = ChartsController(
      ratesService: RatesService(
        client: _FakeRatesClient(),
        cache: _MemoryRatesCache(),
      ),
      range: ChartRange.twoYears,
    );

    controller.setPair('USD', 'BTC');

    expect(controller.state.range, ChartRange.oneYear);
  });

  test('rates service fetches newer weekend gap for crypto pair', () async {
    final cached = HistoricalSnapshot(
      base: 'BTC',
      quote: 'ETH',
      coveredFrom: DateTime(2026, 5, 12),
      coveredTo: DateTime(2026, 5, 15),
      data: <DateTime, double>{DateTime(2026, 5, 15): 40},
      savedAt: DateTime.now(),
    );
    final service = RatesService(
      client: _FakeRatesClient(
        historical: HistoricalSnapshot(
          base: 'BTC',
          quote: 'ETH',
          coveredFrom: DateTime(2026, 5, 16),
          coveredTo: DateTime(2026, 5, 18),
          data: <DateTime, double>{DateTime(2026, 5, 18): 38},
          savedAt: DateTime.now(),
        ),
      ),
      cache: _MemoryRatesCache(historical: cached),
    );

    final result = await service.getHistoricalRates(
      base: 'BTC',
      quote: 'ETH',
      from: DateTime(2026, 5, 12),
      to: DateTime(2026, 5, 18),
    );

    expect(result.snapshot?.data[DateTime(2026, 5, 18)], 38);
  });
}

CryptoUsdHistorySnapshot _cryptoHistory(
  String code,
  Map<DateTime, double> data,
) {
  return CryptoUsdHistorySnapshot(
    code: code,
    coveredFrom: data.keys.reduce((a, b) => a.isBefore(b) ? a : b),
    coveredTo: data.keys.reduce((a, b) => a.isAfter(b) ? a : b),
    savedAt: DateTime.now(),
    pricesUsd: data,
  );
}

class _FakeCryptoUsdHistoryClient implements CryptoUsdHistoryClient {
  _FakeCryptoUsdHistoryClient({required this.snapshots});

  final Map<String, CryptoUsdHistorySnapshot> snapshots;

  @override
  Future<CryptoUsdHistorySnapshot> fetchUsdHistory({
    required String code,
    required DateTime from,
    required DateTime to,
  }) async {
    return snapshots[code] ??
        (throw const CryptoUsdHistoryException('missing test snapshot'));
  }
}

class _FakeFrankfurterClient extends FrankfurterClient {
  _FakeFrankfurterClient({this.historical});

  final HistoricalSnapshot? historical;

  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    return historical ??
        HistoricalSnapshot(
          base: base,
          quote: quote,
          coveredFrom: from,
          coveredTo: to,
          data: <DateTime, double>{from: 1},
          savedAt: DateTime.now(),
        );
  }
}

class _ThrowingUsdUsdFrankfurterClient extends FrankfurterClient {
  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    if (base == 'USD' && quote == 'USD') {
      throw StateError('USD/USD should not hit Frankfurter');
    }

    return HistoricalSnapshot(
      base: base,
      quote: quote,
      coveredFrom: from,
      coveredTo: to,
      data: <DateTime, double>{from: 1},
      savedAt: DateTime.now(),
    );
  }
}

class _StaticHttpClient extends http.BaseClient {
  _StaticHttpClient(this.body);

  final String body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream<List<int>>.value(body.codeUnits), 200);
  }
}

class _FakeRatesClient implements RatesClient {
  _FakeRatesClient({HistoricalSnapshot? historical})
    : _historical =
          historical ??
          HistoricalSnapshot(
            base: 'BTC',
            quote: 'ETH',
            coveredFrom: DateTime(2026, 5, 16),
            coveredTo: DateTime(2026, 5, 18),
            data: <DateTime, double>{DateTime(2026, 5, 18): 38},
            savedAt: DateTime.now(),
          );

  final HistoricalSnapshot _historical;

  @override
  Future<RatesSnapshot> fetchLatest(String base) async {
    return RatesSnapshot(
      base: base,
      date: DateTime(2026, 5, 18),
      savedAt: DateTime.now(),
      rates: const <String, double>{'EUR': .92},
    );
  }

  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    return _historical;
  }
}

class _MemoryRatesCache implements RatesCache {
  _MemoryRatesCache({this.historical});

  final HistoricalSnapshot? historical;

  @override
  Future<void> clear() async {}

  @override
  Future<void> invalidateHistorical({
    required String base,
    required String quote,
  }) async {}

  @override
  Future<void> invalidateLatest(String base) async {}

  @override
  Future<HistoricalSnapshot?> readHistorical({
    required String base,
    required String quote,
  }) async {
    return historical;
  }

  @override
  Future<RatesSnapshot?> readLatest(String base) async => null;

  @override
  Future<void> writeHistorical(HistoricalSnapshot snapshot) async {}

  @override
  Future<void> writeLatest(RatesSnapshot snapshot) async {}
}
