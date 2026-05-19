class CryptoUsdHistorySnapshot {
  const CryptoUsdHistorySnapshot({
    required this.code,
    required this.coveredFrom,
    required this.coveredTo,
    required this.savedAt,
    required this.pricesUsd,
  });

  final String code;
  final DateTime coveredFrom;
  final DateTime coveredTo;
  final DateTime savedAt;
  final Map<DateTime, double> pricesUsd;

  bool covers(DateTime from, DateTime to) {
    return !coveredFrom.isAfter(from) && !coveredTo.isBefore(to);
  }

  CryptoUsdHistorySnapshot mergedWith(CryptoUsdHistorySnapshot newer) {
    final merged = Map<DateTime, double>.from(pricesUsd)
      ..addAll(newer.pricesUsd);
    final mergedFrom = coveredFrom.isBefore(newer.coveredFrom)
        ? coveredFrom
        : newer.coveredFrom;
    final mergedTo = coveredTo.isAfter(newer.coveredTo)
        ? coveredTo
        : newer.coveredTo;

    return CryptoUsdHistorySnapshot(
      code: code,
      coveredFrom: mergedFrom,
      coveredTo: mergedTo,
      savedAt: newer.savedAt,
      pricesUsd: merged,
    );
  }
}
