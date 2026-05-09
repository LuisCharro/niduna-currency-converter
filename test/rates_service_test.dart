import 'package:currency_converter/src/core/rates/models/rates_snapshot.dart';
import 'package:currency_converter/src/core/rates/models/rates_result.dart';
import 'package:currency_converter/src/core/rates/rates_cache.dart';
import 'package:currency_converter/src/core/rates/rates_client.dart';
import 'package:currency_converter/src/core/rates/rates_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fresh latest cache returns without a network refresh', () async {
    final cache = _MemoryRatesCache(latest: _latest(savedAt: DateTime.now()));
    final client = _FakeRatesClient();
    final service = RatesService(client: client, cache: cache);

    final result = await service.getLatestRates('USD');

    expect(result.status, RatesStatus.cached);
    expect(result.snapshot?.rates['EUR'], .92);
    expect(client.latestCalls, 0);
  });

  test('stale latest cache returns immediately and refreshes once', () async {
    final cache = _MemoryRatesCache(
      latest: _latest(
        savedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );
    final client = _FakeRatesClient(
      latest: _latest(rate: .94, savedAt: DateTime.now()),
    );
    final service = RatesService(client: client, cache: cache);

    final result = await service.getLatestRates('USD');
    await Future<void>.delayed(Duration.zero);

    expect(result.status, RatesStatus.stale);
    expect(result.snapshot?.rates['EUR'], .92);
    expect(client.latestCalls, 1);
    expect((await cache.readLatest('USD'))?.rates['EUR'], .94);
  });

  test('concurrent latest misses share one network request', () async {
    final cache = _MemoryRatesCache();
    final client = _FakeRatesClient(
      latest: _latest(savedAt: DateTime.now()),
      delay: const Duration(milliseconds: 1),
    );
    final service = RatesService(client: client, cache: cache);

    final results = await Future.wait(<Future<RatesResult>>[
      service.getLatestRates('USD'),
      service.getLatestRates('USD'),
      service.getLatestRates('USD'),
    ]);

    expect(
      results.map((result) => result.status),
      everyElement(RatesStatus.fresh),
    );
    expect(client.latestCalls, 1);
  });

  test('historical cache returns without network', () async {
    final snapshot = _historical();
    final cache = _MemoryRatesCache(historical: snapshot);
    final client = _FakeRatesClient();
    final service = RatesService(client: client, cache: cache);

    final result = await service.getHistoricalRates(
      base: 'USD',
      quote: 'EUR',
      rangeKey: snapshot.rangeKey,
      from: DateTime(2026, 5, 1),
      to: DateTime(2026, 5, 9),
    );

    expect(result.status, HistoricalStatus.cached);
    expect(result.snapshot?.data.length, 2);
    expect(client.historicalCalls, 0);
  });

  test('historical refresh falls back to cached data on failure', () async {
    final snapshot = _historical();
    final cache = _MemoryRatesCache(historical: snapshot);
    final client = _FakeRatesClient(shouldFailHistorical: true);
    final service = RatesService(client: client, cache: cache);

    final result = await service.getHistoricalRates(
      base: 'USD',
      quote: 'EUR',
      rangeKey: snapshot.rangeKey,
      from: DateTime(2026, 5, 1),
      to: DateTime(2026, 5, 9),
      forceRefresh: true,
    );

    expect(result.status, HistoricalStatus.cached);
    expect(result.snapshot, snapshot);
    expect(client.historicalCalls, 1);
  });
}

RatesSnapshot _latest({double rate = .92, required DateTime savedAt}) {
  return RatesSnapshot(
    base: 'USD',
    date: DateTime(2026, 5, 8),
    savedAt: savedAt,
    rates: <String, double>{'EUR': rate},
  );
}

HistoricalSnapshot _historical() {
  return HistoricalSnapshot(
    base: 'USD',
    quote: 'EUR',
    rangeKey: '2026-05-01_2026-05-09',
    data: <DateTime, double>{
      DateTime(2026, 5, 1): .91,
      DateTime(2026, 5, 2): .92,
    },
    savedAt: DateTime.now(),
  );
}

class _FakeRatesClient implements RatesClient {
  _FakeRatesClient({
    RatesSnapshot? latest,
    HistoricalSnapshot? historical,
    this.delay = Duration.zero,
    this.shouldFailHistorical = false,
  }) : latest = latest ?? _latest(savedAt: DateTime.now()),
       historical = historical ?? _historical();

  final RatesSnapshot latest;
  final HistoricalSnapshot historical;
  final Duration delay;
  final bool shouldFailHistorical;
  int latestCalls = 0;
  int historicalCalls = 0;

  @override
  Future<RatesSnapshot> fetchLatest(String base) async {
    latestCalls += 1;
    await Future<void>.delayed(delay);
    return latest;
  }

  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    historicalCalls += 1;
    if (shouldFailHistorical) {
      throw const RatesClientException('offline');
    }
    return historical;
  }
}

class _MemoryRatesCache implements RatesCache {
  _MemoryRatesCache({RatesSnapshot? latest, HistoricalSnapshot? historical}) {
    if (latest != null) {
      _latest[latest.base] = latest;
    }
    if (historical != null) {
      _historical[_historicalKey(
            historical.base,
            historical.quote,
            historical.rangeKey,
          )] =
          historical;
    }
  }

  final Map<String, RatesSnapshot> _latest = <String, RatesSnapshot>{};
  final Map<String, HistoricalSnapshot> _historical =
      <String, HistoricalSnapshot>{};

  @override
  Future<RatesSnapshot?> readLatest(String base) async => _latest[base];

  @override
  Future<void> writeLatest(RatesSnapshot snapshot) async {
    _latest[snapshot.base] = snapshot;
  }

  @override
  Future<void> invalidateLatest(String base) async {
    _latest.remove(base);
  }

  @override
  Future<HistoricalSnapshot?> readHistorical({
    required String base,
    required String quote,
    required String rangeKey,
  }) async {
    return _historical[_historicalKey(base, quote, rangeKey)];
  }

  @override
  Future<void> writeHistorical(HistoricalSnapshot snapshot) async {
    _historical[_historicalKey(
          snapshot.base,
          snapshot.quote,
          snapshot.rangeKey,
        )] =
        snapshot;
  }

  @override
  Future<void> invalidateHistorical({
    required String base,
    required String quote,
    required String rangeKey,
  }) async {
    _historical.remove(_historicalKey(base, quote, rangeKey));
  }

  @override
  Future<void> clear() async {
    _latest.clear();
    _historical.clear();
  }

  String _historicalKey(String base, String quote, String rangeKey) =>
      '$base|$quote|$rangeKey';
}
