class LatestRatesSnapshot {
  const LatestRatesSnapshot({
    required this.base,
    required this.date,
    required this.savedAt,
    required this.rates,
  });

  final String base;
  final DateTime? date;
  final DateTime savedAt;
  final Map<String, double> rates;
}
