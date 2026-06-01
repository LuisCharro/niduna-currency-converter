import 'dart:convert';

import 'package:currency_converter/src/core/rates/clients/frankfurter_client.dart';
import 'package:currency_converter/src/core/rates/crypto/coinpaprika_crypto_usd_history_client.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_history_cache.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_history_client.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_usd_history_snapshot.dart';
import 'package:currency_converter/src/core/rates/crypto/fawazahmed_crypto_usd_history_client.dart';
import 'package:currency_converter/src/core/rates/models/rates_snapshot.dart';
import 'package:currency_converter/src/core/rates/multi_provider_rates_client.dart';
import 'package:currency_converter/src/core/rates/provider_config.dart';
import 'package:currency_converter/src/core/rates/provider_factory.dart';
import 'package:currency_converter/src/core/rates/rates_cache.dart';
import 'package:currency_converter/src/core/rates/rates_client.dart';
import 'package:currency_converter/src/core/rates/rates_service.dart';
import 'package:currency_converter/src/features/charts/data/rates_service_chart_repository.dart';
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

  test(
    'multi-provider client handles USD to BTC without Frankfurter USD/USD',
    () async {
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
    },
  );

  test(
    'multi-provider client handles BTC to USD without Frankfurter USD/USD',
    () async {
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
    },
  );

  test('charts controller downgrades 2Y to 1Y for crypto pair', () {
    final controller = ChartsController(
      allowCryptoCharts: true,
      repository: RatesServiceChartRepository(RatesService(
        client: _FakeRatesClient(),
        cache: _MemoryRatesCache(),
      )),
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

  test('fawazahmed0 history client parses and inverts BTC/ETH from CDN', () async {
    final client = FawazahmedCryptoUsdHistoryClient(
      client: _StaticHttpClient(
        '{"date":"2024-03-06","usd":{"btc":0.000015192,"eth":0.0002658303}}',
      ),
    );

    final snapshot = await client.fetchUsdHistory(
      code: 'BTC',
      from: DateTime(2024, 3, 6),
      to: DateTime(2024, 3, 6),
    );

    expect(snapshot.code, 'BTC');
    expect(snapshot.pricesUsd[DateTime(2024, 3, 6)], closeTo(65824.12, 50));
  });

  test('fawazahmed0 history client tolerates mixed success/failure per date', () async {
    final client = FawazahmedCryptoUsdHistoryClient(
      client: _MixedSuccessHttpClient(),
    );

    final snapshot = await client.fetchUsdHistory(
      code: 'BTC',
      from: DateTime(2024, 3, 5),
      to: DateTime(2024, 3, 7),
    );

    expect(snapshot.code, 'BTC');
    expect(snapshot.pricesUsd.length, greaterThanOrEqualTo(1));
    expect(snapshot.pricesUsd[DateTime(2024, 3, 6)], closeTo(65824.12, 50));
  });

  test('fawazahmed0 history client skips 404 days gracefully', () async {
    final client = FawazahmedCryptoUsdHistoryClient(
      client: _StatusCodeHttpClient(404),
    );

    try {
      await client.fetchUsdHistory(
        code: 'BTC',
        from: DateTime(2024, 3, 6),
        to: DateTime(2024, 3, 6),
      );
      fail('Should have thrown');
    } on CryptoUsdHistoryException catch (e) {
      expect(e.message, contains('no data'));
    }
  });

  test('release_safe profile uses fawazahmed0 for crypto history', () {
    expect(
      ProviderConfig.cryptoHistoryProvider,
      CryptoHistoryProvider.fawazahmed0,
    );
  });

  test('factory creates fawazahmed0 history client for release_safe', () {
    final client = ProviderFactory.createCryptoHistoryClient();
    expect(client, isA<FawazahmedCryptoUsdHistoryClient>());
  });

  // ---------- Phase 1.x coverage: multi-day series + controller pair/range ----------

  test('multi-provider client composes BTC to ETH over a 5-day range', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final client = MultiProviderRatesClient(
      fiatClient: _FakeFrankfurterClient(),
      cryptoHistoryClient: _FakeCryptoUsdHistoryClient(
        snapshots: <String, CryptoUsdHistorySnapshot>{
          'BTC': _cryptoHistory('BTC', <DateTime, double>{
            DateTime(2026, 5, 12): 80000,
            DateTime(2026, 5, 13): 81000,
            DateTime(2026, 5, 14): 79500,
            DateTime(2026, 5, 15): 82000,
            DateTime(2026, 5, 16): 83000,
          }),
          'ETH': _cryptoHistory('ETH', <DateTime, double>{
            DateTime(2026, 5, 12): 2000,
            DateTime(2026, 5, 13): 2010,
            DateTime(2026, 5, 14): 1990,
            DateTime(2026, 5, 15): 2050,
            DateTime(2026, 5, 16): 2070,
          }),
        },
      ),
      cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
    );

    final result = await client.fetchHistorical(
      base: 'BTC',
      quote: 'ETH',
      from: DateTime(2026, 5, 12),
      to: DateTime(2026, 5, 16),
    );

    // Spot-check 3 of 5 days: each = btcUsd / ethUsd.
    expect(result.data[DateTime(2026, 5, 12)], closeTo(40, 0.001));
    expect(result.data[DateTime(2026, 5, 14)], closeTo(79500 / 1990, 0.001));
    expect(result.data[DateTime(2026, 5, 16)], closeTo(83000 / 2070, 0.001));
  });

  test(
    'multi-provider client carries forward fiat close across multi-day EUR to BTC',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final client = MultiProviderRatesClient(
        fiatClient: _FakeFrankfurterClient(
          historical: HistoricalSnapshot(
            base: 'EUR',
            quote: 'USD',
            coveredFrom: DateTime(2026, 5, 15),
            coveredTo: DateTime(2026, 5, 17),
            data: <DateTime, double>{
              DateTime(2026, 5, 15): 1.20,
              DateTime(2026, 5, 16): 1.20,
              DateTime(2026, 5, 17): 1.20,
            },
            savedAt: DateTime.now(),
          ),
        ),
        cryptoHistoryClient: _FakeCryptoUsdHistoryClient(
          snapshots: <String, CryptoUsdHistorySnapshot>{
            'BTC': _cryptoHistory('BTC', <DateTime, double>{
              DateTime(2026, 5, 16): 60000,
              DateTime(2026, 5, 17): 61000,
            }),
          },
        ),
        cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
      );

      final result = await client.fetchHistorical(
        base: 'EUR',
        quote: 'BTC',
        from: DateTime(2026, 5, 16),
        to: DateTime(2026, 5, 17),
      );

      // Carry-forward: EUR→USD at the available date, then ÷ BTC/USD.
      // 1.20 / 60000 = 0.00002, 1.20 / 61000 ≈ 0.0000196721
      expect(result.data[DateTime(2026, 5, 16)], closeTo(0.00002, 0.000000001));
      expect(result.data[DateTime(2026, 5, 17)], closeTo(1.20 / 61000, 0.0000001));
    },
  );

  test(
    'ChartsController.swapPair keeps 1Y range for crypto-involved pair',
    () {
      // USD/BTC is crypto. Controller starts at 1Y. After swap, BTC/USD is
      // also crypto, so 1Y must persist (no upgrade to 2Y, no downgrade).
      final controller = ChartsController(
        allowCryptoCharts: true,
        repository: RatesServiceChartRepository(RatesService(
          client: _FakeRatesClient(),
          cache: _MemoryRatesCache(),
        )),
        range: ChartRange.oneYear,
      );
      controller.setPair('USD', 'BTC');
      expect(controller.state.range, ChartRange.oneYear);
      expect(controller.state.base, 'USD');
      expect(controller.state.quote, 'BTC');

      controller.swapPair();
      expect(controller.state.base, 'BTC');
      expect(controller.state.quote, 'USD');
      // Still crypto-involved → 1Y must stay, not upgrade to 2Y.
      expect(controller.state.range, ChartRange.oneYear);
    },
  );

  test(
    'ChartsController.setRange downgrades 2Y to 1Y for crypto pair',
    () {
      // Start with fiat pair at 2Y (fine for fiat), then setPair to crypto.
      // The 2Y must auto-downgrade to 1Y.
      final controller = ChartsController(
        allowCryptoCharts: true,
        repository: RatesServiceChartRepository(RatesService(
          client: _FakeRatesClient(),
          cache: _MemoryRatesCache(),
        )),
        range: ChartRange.twoYears,
      );
      expect(controller.state.range, ChartRange.twoYears);

      controller.setPair('USD', 'BTC');
      expect(controller.state.range, ChartRange.oneYear);

      // Switching back to fiat at 1Y, then bumping to 2Y must work.
      controller.setPair('USD', 'EUR');
      expect(controller.state.range, ChartRange.oneYear);
      controller.setRange(ChartRange.twoYears);
      expect(controller.state.range, ChartRange.twoYears);
    },
  );
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

class _StatusCodeHttpClient extends http.BaseClient {
  _StatusCodeHttpClient(this.statusCode);

  final int statusCode;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      const Stream.empty(),
      statusCode,
      request: request,
    );
  }
}

class _MixedSuccessHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final url = request.url.toString();
    if (url.contains('2024-03-06')) {
      return http.StreamedResponse(
        Stream.fromIterable([
          utf8.encode(
            '{"date":"2024-03-06","usd":{"btc":0.000015192}}',
          ),
        ]),
        200,
        request: request,
      );
    }
    return http.StreamedResponse(
      const Stream.empty(),
      404,
      request: request,
    );
  }
}
