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
    required this.rangeKey,
    required this.data,
    required this.savedAt,
  });

  final String base;
  final String quote;
  final String rangeKey;
  final Map<DateTime, double> data;
  final DateTime savedAt;

  bool get isEmpty => data.isEmpty;
}
