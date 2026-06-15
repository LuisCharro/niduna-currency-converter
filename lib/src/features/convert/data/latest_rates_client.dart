import '../domain/latest_rates_snapshot.dart';

abstract class LatestRatesClient {
  Future<LatestRatesSnapshot> fetchLatest(String base);

  /// Rates for the business day before [referenceDate] (the latest published
  /// rate date). Defaults to the day before today when [referenceDate] is
  /// null. Used to compute the day-over-day trend.
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) async => null;
}
