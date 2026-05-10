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
      from: DateTime(2026, 5, 1),
      to: DateTime(2026, 5, 9),
      forceRefresh: true,
    );

    expect(result.status, HistoricalStatus.cached);
    expect(result.snapshot?.base, snapshot.base);
    expect(result.snapshot?.quote, snapshot.quote);
    expect(result.snapshot?.data, snapshot.data);
    expect(client.historicalCalls, 1);
  });

  test('historical 1Y to 2Y fetches only missing older segment', () async {
    final recentYear = _historical(
      coveredFrom: DateTime(2025, 5, 10),
      coveredTo: DateTime(2026, 5, 10),
      data: <DateTime, double>{
        DateTime(2025, 5, 10): .91,
        DateTime(2026, 5, 10): .95,
      },
      savedAt: DateTime.now(),
    );
    final olderYear = _historical(
      coveredFrom: DateTime(2024, 5, 10),
      coveredTo: DateTime(2025, 5, 9),
      data: <DateTime, double>{
        DateTime(2024, 5, 10): .88,
        DateTime(2025, 5, 9): .90,
      },
      savedAt: DateTime.now(),
    );

    final cache = _MemoryRatesCache(historical: recentYear);
    final client = _FakeRatesClient(historicalSequence: <HistoricalSnapshot>[olderYear]);
    final service = RatesService(client: client, cache: cache);

    final result = await service.getHistoricalRates(
      base: 'USD',
      quote: 'EUR',
      from: DateTime(2024, 5, 10),
      to: DateTime(2026, 5, 10),
    );

    expect(client.historicalCalls, 1);
    expect(result.snapshot?.data.length, 4);
    expect(result.snapshot?.coveredFrom, DateTime(2024, 5, 10));
    expect(result.snapshot?.coveredTo, DateTime(2026, 5, 10));
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

HistoricalSnapshot _historical({
  DateTime? coveredFrom,
  DateTime? coveredTo,
  Map<DateTime, double>? data,
  DateTime? savedAt,
}) {
  return HistoricalSnapshot(
    base: 'USD',
    quote: 'EUR',
    coveredFrom: coveredFrom ?? DateTime(2026, 5, 1),
    coveredTo: coveredTo ?? DateTime(2026, 5, 9),
    data:
        data ??
        <DateTime, double>{
          DateTime(2026, 5, 1): .91,
          DateTime(2026, 5, 9): .92,
        },
    savedAt: savedAt ?? DateTime.now(),
  );
}

class _FakeRatesClient implements RatesClient {
  _FakeRatesClient({
    RatesSnapshot? latest,
    HistoricalSnapshot? historical,
    List<HistoricalSnapshot>? historicalSequence,
    this.delay = Duration.zero,
    this.shouldFailHistorical = false,
  }) : latest = latest ?? _latest(savedAt: DateTime.now()),
       historical = historical ?? _historical(),
       historicalSequence = historicalSequence ?? <HistoricalSnapshot>[];

  final RatesSnapshot latest;
  final HistoricalSnapshot historical;
  final List<HistoricalSnapshot> historicalSequence;
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
    if (historicalSequence.isNotEmpty) {
      return historicalSequence.removeAt(0);
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
      _historical[_historicalKey(historical.base, historical.quote)] =
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
  }) async {
    return _historical[_historicalKey(base, quote)];
  }

  @override
  Future<void> writeHistorical(HistoricalSnapshot snapshot) async {
    final key = _historicalKey(snapshot.base, snapshot.quote);
    final existing = _historical[key];
    _historical[key] = existing == null ? snapshot : existing.mergedWith(snapshot);
  }

  @override
  Future<void> invalidateHistorical({
    required String base,
    required String quote,
  }) async {
    _historical.remove(_historicalKey(base, quote));
  }

  @override
  Future<void> clear() async {
    _latest.clear();
    _historical.clear();
  }

  String _historicalKey(String base, String quote) => '$base|$quote';
}
