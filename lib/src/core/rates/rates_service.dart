import 'dart:async';

import 'models/rates_result.dart';
import 'rates_cache.dart';
import 'rates_client.dart';
import 'rates_service_helpers.dart' as helpers;

class RatesService {
  RatesService({required RatesClient client, required RatesCache cache})
    : _client = client,
      _cache = cache,
      _historicalFetcher = helpers.HistoricalFetcher(client: client, cache: cache);

  final RatesClient _client;
  final RatesCache _cache;
  final helpers.HistoricalFetcher _historicalFetcher;
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

    final fromDate = helpers.toDateOnly(from);
    final toDate = helpers.toDateOnly(to);

    final cached = await _cache.readHistorical(base: base, quote: quote);
    if (cached != null) {
      final coversRange = helpers.coversRange(cached, fromDate, toDate);
      if (coversRange && !forceRefresh && !cached.isStale()) {
        return HistoricalResult(
          status: HistoricalStatus.cached,
          snapshot: helpers.filterSnapshot(cached, fromDate, toDate),
        );
      }
    }

    final key = helpers.historicalKey(base, quote, fromDate, toDate);
    final existing = _historicalRequests[key];
    if (existing != null) {
      return existing;
    }

    final request = _historicalFetcher.fetchSmart(
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

  Future<void> invalidateCache(String base) async {
    await _cache.invalidateLatest(base);
  }

  Future<void> clearCache() async {
    await _cache.clear();
  }
}
