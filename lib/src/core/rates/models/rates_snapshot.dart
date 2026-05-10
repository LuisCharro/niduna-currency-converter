class RatesSnapshot {
  const RatesSnapshot({
    required this.base,
    required this.date,
    required this.savedAt,
    required this.rates,
  });

  final String base;
  final DateTime? date;
  final DateTime savedAt;
  final Map<String, double> rates;

  bool isStale({Duration maxAge = const Duration(hours: 1)}) {
    return DateTime.now().difference(savedAt) > maxAge;
  }
}

class HistoricalSnapshot {
  const HistoricalSnapshot({
    required this.base,
    required this.quote,
    required this.coveredFrom,
    required this.coveredTo,
    required this.data,
    required this.savedAt,
  });

  final String base;
  final String quote;
  final DateTime coveredFrom;
  final DateTime coveredTo;
  final Map<DateTime, double> data;
  final DateTime savedAt;

  bool get isEmpty => data.isEmpty;

  bool isStale({Duration maxAge = const Duration(hours: 4)}) {
    return DateTime.now().difference(savedAt) > maxAge;
  }

  HistoricalSnapshot mergedWith(HistoricalSnapshot newer) {
    final mergedData = Map<DateTime, double>.from(data)
      ..addAll(newer.data);
    final mergedFrom = coveredFrom.isBefore(newer.coveredFrom)
        ? coveredFrom
        : newer.coveredFrom;
    final mergedTo = coveredTo.isAfter(newer.coveredTo)
        ? coveredTo
        : newer.coveredTo;

    return HistoricalSnapshot(
      base: base,
      quote: quote,
      coveredFrom: mergedFrom,
      coveredTo: mergedTo,
      data: mergedData,
      savedAt: newer.savedAt,
    );
  }
}
