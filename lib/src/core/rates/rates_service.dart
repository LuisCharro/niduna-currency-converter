import 'dart:async';

import 'models/rates_snapshot.dart';
import 'models/rates_result.dart';
import 'rates_cache.dart';
import 'rates_client.dart';

class RatesService {
  RatesService({required RatesClient client, required RatesCache cache})
    : _client = client,
      _cache = cache;

  final RatesClient _client;
  final RatesCache _cache;
  final Map<String, Future<RatesResult>> _latestRequests = {};
  final Map<String, Future<HistoricalResult>> _historicalRequests = {};

  Future<RatesResult> getLatestRates(
    String base, {
    bool forceRefresh = false,
    Duration maxAge = const Duration(hours: 1),
  }) async {
    if (forceRefresh) {
      return _fetchAndCacheLatest(base);
    }

    final cached = await _cache.readLatest(base);

    if (cached != null) {
      if (!cached.isStale(maxAge: maxAge)) {
        return RatesResult(status: RatesStatus.cached, snapshot: cached);
      } else {
        _refreshLatestInBackground(base);
        return RatesResult(
          status: RatesStatus.stale,
          snapshot: cached,
          message: 'Rates may be outdated. Refreshing...',
        );
      }
    }

    return _fetchAndCacheLatest(base);
  }

  Future<RatesResult> _fetchAndCacheLatest(String base) async {
    final existing = _latestRequests[base];
    if (existing != null) {
      return existing;
    }

    final request = _fetchAndCacheLatestUnshared(base);
    _latestRequests[base] = request;
    try {
      return await request;
    } finally {
      _latestRequests.remove(base);
    }
  }

  Future<RatesResult> _fetchAndCacheLatestUnshared(String base) async {
    try {
      final fresh = await _client.fetchLatest(base);
      await _cache.writeLatest(fresh);
      return RatesResult(status: RatesStatus.fresh, snapshot: fresh);
    } catch (e) {
      final cached = await _cache.readLatest(base);
      if (cached != null) {
        return RatesResult(
          status: RatesStatus.error,
          snapshot: cached,
          message: 'Network unavailable. Showing cached rates.',
        );
      }
      return RatesResult(
        status: RatesStatus.noCache,
        message: 'Connect to the internet to load rates.',
      );
    }
  }

  void _refreshLatestInBackground(String base) {
    unawaited(_fetchAndCacheLatest(base));
  }

  Future<HistoricalResult> getHistoricalRates({
    required String base,
    required String quote,
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  }) async {
    if (from == null || to == null) {
      return const HistoricalResult(
        status: HistoricalStatus.noCache,
        message: 'Invalid date range for historical data.',
      );
    }

    final fromDate = _toDateOnly(from);
    final toDate = _toDateOnly(to);

    final cached = await _cache.readHistorical(base: base, quote: quote);
    if (cached != null) {
      final coversRange = _coversRange(cached, fromDate, toDate);
      if (coversRange && !forceRefresh && !cached.isStale()) {
        return HistoricalResult(
          status: HistoricalStatus.cached,
          snapshot: _filterSnapshot(cached, fromDate, toDate),
        );
      }
    }

    final key = _historicalKey(base, quote, fromDate, toDate);
    final existing = _historicalRequests[key];
    if (existing != null) {
      return existing;
    }

    final request = _fetchAndCacheHistoricalSmart(
      base: base,
      quote: quote,
      from: fromDate,
      to: toDate,
      fallback: cached,
      forceRefresh: forceRefresh,
    );
    _historicalRequests[key] = request;
    try {
      return await request;
    } finally {
      _historicalRequests.remove(key);
    }
  }

  Future<HistoricalResult> _fetchAndCacheHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
    HistoricalSnapshot? fallback,
  }) async {
    try {
      final snapshot = await _client.fetchHistorical(
        base: base,
        quote: quote,
        from: from,
        to: to,
      );
      await _cache.writeHistorical(snapshot);
      return HistoricalResult(
        status: HistoricalStatus.fresh,
        snapshot: snapshot,
      );
    } catch (e) {
      if (fallback != null) {
        return HistoricalResult(
          status: HistoricalStatus.cached,
          snapshot: fallback,
          message: 'Failed to refresh historical data. Showing cached data.',
        );
      }
      return HistoricalResult(
        status: HistoricalStatus.error,
        message: 'Failed to load historical data: ${e.toString()}',
      );
    }
  }

  Future<HistoricalResult> _fetchAndCacheHistoricalSmart({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
    required bool forceRefresh,
    HistoricalSnapshot? fallback,
  }) async {
    final cached = fallback;
    if (cached == null) {
      return _fetchAndCacheHistorical(
        base: base,
        quote: quote,
        from: from,
        to: to,
      );
    }

    var merged = cached;
    var fetchedFresh = false;

    if (!_coversRange(merged, from, to)) {
      if (merged.coveredFrom.isAfter(from)) {
        final olderTo = _toDateOnly(
          merged.coveredFrom.subtract(const Duration(days: 1)),
        );
        if (!olderTo.isBefore(from)) {
          final olderResult = await _fetchAndCacheHistorical(
            base: base,
            quote: quote,
            from: from,
            to: olderTo,
            fallback: merged,
          );
          final olderSnapshot = olderResult.snapshot;
          if (olderSnapshot != null) {
            merged = merged.mergedWith(olderSnapshot);
            fetchedFresh =
                fetchedFresh || olderResult.status == HistoricalStatus.fresh;
          }
        }
      }

      if (merged.coveredTo.isBefore(to) &&
          _shouldFetchNewerGap(merged.coveredTo, to)) {
        final newerFrom = _toDateOnly(
          merged.coveredTo.add(const Duration(days: 1)),
        );
        if (!newerFrom.isAfter(to)) {
          final newerResult = await _fetchAndCacheHistorical(
            base: base,
            quote: quote,
            from: newerFrom,
            to: to,
            fallback: merged,
          );
          final newerSnapshot = newerResult.snapshot;
          if (newerSnapshot != null) {
            merged = merged.mergedWith(newerSnapshot);
            fetchedFresh =
                fetchedFresh || newerResult.status == HistoricalStatus.fresh;
          }
        }
      }
    }

    if (forceRefresh || merged.isStale()) {
      final refreshFrom = _toDateOnly(merged.coveredTo);
      final refreshResult = await _fetchAndCacheHistorical(
        base: base,
        quote: quote,
        from: refreshFrom,
        to: to,
        fallback: merged,
      );
      if (refreshResult.snapshot != null) {
        merged = merged.mergedWith(refreshResult.snapshot!);
        fetchedFresh =
            fetchedFresh || refreshResult.status == HistoricalStatus.fresh;
      }
    }

    final status = fetchedFresh
        ? HistoricalStatus.fresh
        : HistoricalStatus.cached;
    return HistoricalResult(
      status: status,
      snapshot: _filterSnapshot(merged, from, to),
    );
  }

  Future<void> invalidateCache(String base) async {
    await _cache.invalidateLatest(base);
  }

  Future<void> clearCache() async {
    await _cache.clear();
  }

  String _historicalKey(
    String base,
    String quote,
    DateTime from,
    DateTime to,
  ) => '$base|$quote|${from.toIso8601String()}|${to.toIso8601String()}';

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _coversRange(HistoricalSnapshot snapshot, DateTime from, DateTime to) {
    return !snapshot.coveredFrom.isAfter(from) &&
        !snapshot.coveredTo.isBefore(to);
  }

  bool _shouldFetchNewerGap(DateTime coveredTo, DateTime requestedTo) {
    final to = _toDateOnly(requestedTo);
    final lastCovered = _toDateOnly(coveredTo);
    if (!lastCovered.isBefore(to)) {
      return false;
    }

    if (!_isWeekend(to)) {
      return true;
    }

    final weekendSpan = to.difference(lastCovered).inDays;
    return weekendSpan > 2;
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  HistoricalSnapshot _filterSnapshot(
    HistoricalSnapshot snapshot,
    DateTime from,
    DateTime to,
  ) {
    final filtered = <DateTime, double>{};
    for (final entry in snapshot.data.entries) {
      final date = _toDateOnly(entry.key);
      if (!date.isBefore(from) && !date.isAfter(to)) {
        filtered[date] = entry.value;
      }
    }

    if (filtered.isEmpty) {
      return HistoricalSnapshot(
        base: snapshot.base,
        quote: snapshot.quote,
        coveredFrom: from,
        coveredTo: to,
        data: const {},
        savedAt: snapshot.savedAt,
      );
    }

    final minDate = filtered.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = filtered.keys.reduce((a, b) => a.isAfter(b) ? a : b);
    return HistoricalSnapshot(
      base: snapshot.base,
      quote: snapshot.quote,
      coveredFrom: minDate,
      coveredTo: maxDate,
      data: filtered,
      savedAt: snapshot.savedAt,
    );
  }
}
