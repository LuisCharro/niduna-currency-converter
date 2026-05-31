import '../currency/supported_currencies.dart';
import 'models/rates_snapshot.dart';
import 'models/rates_result.dart';
import 'rates_cache.dart';
import 'rates_client.dart';

DateTime toDateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String historicalKey(
  String base,
  String quote,
  DateTime from,
  DateTime to,
) => '$base|$quote|${from.toIso8601String()}|${to.toIso8601String()}';

bool coversRange(HistoricalSnapshot snapshot, DateTime from, DateTime to) {
  return !snapshot.coveredFrom.isAfter(from) &&
      !snapshot.coveredTo.isBefore(to);
}

bool shouldFetchNewerGap(
  DateTime coveredTo,
  DateTime requestedTo,
  String base,
  String quote,
) {
  final to = toDateOnly(requestedTo);
  final lastCovered = toDateOnly(coveredTo);
  if (!lastCovered.isBefore(to)) {
    return false;
  }

  if (isCryptoCurrency(base) || isCryptoCurrency(quote)) {
    return true;
  }

  if (!isWeekend(to)) {
    return true;
  }

  final weekendSpan = to.difference(lastCovered).inDays;
  return weekendSpan > 2;
}

bool isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

HistoricalSnapshot filterSnapshot(
  HistoricalSnapshot snapshot,
  DateTime from,
  DateTime to,
) {
  final filtered = <DateTime, double>{};
  for (final entry in snapshot.data.entries) {
    final date = toDateOnly(entry.key);
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

class HistoricalFetcher {
  HistoricalFetcher({required RatesClient client, required RatesCache cache})
    : _client = client,
      _cache = cache;

  final RatesClient _client;
  final RatesCache _cache;

  Future<HistoricalResult> fetchAndCache({
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

  Future<HistoricalResult> fetchSmart({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
    required bool forceRefresh,
    HistoricalSnapshot? fallback,
  }) async {
    final cached = fallback;
    if (cached == null) {
      return fetchAndCache(
        base: base,
        quote: quote,
        from: from,
        to: to,
      );
    }

    var merged = cached;
    var fetchedFresh = false;

    if (!coversRange(merged, from, to)) {
      if (merged.coveredFrom.isAfter(from)) {
        final olderTo = toDateOnly(
          merged.coveredFrom.subtract(const Duration(days: 1)),
        );
        if (!olderTo.isBefore(from)) {
          final olderResult = await fetchAndCache(
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
          shouldFetchNewerGap(merged.coveredTo, to, base, quote)) {
        final newerFrom = toDateOnly(
          merged.coveredTo.add(const Duration(days: 1)),
        );
        if (!newerFrom.isAfter(to)) {
          final newerResult = await fetchAndCache(
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
      final refreshFrom = toDateOnly(merged.coveredTo);
      final refreshResult = await fetchAndCache(
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
      snapshot: filterSnapshot(merged, from, to),
    );
  }
}
