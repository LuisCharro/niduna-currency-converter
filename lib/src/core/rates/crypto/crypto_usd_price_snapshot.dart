class CryptoUsdPriceSnapshot {
  const CryptoUsdPriceSnapshot({
    required this.provider,
    required this.savedAt,
    required this.pricesUsd,
  });

  final String provider;
  final DateTime savedAt;
  final Map<String, double> pricesUsd;
}
