import '../domain/latest_rates_snapshot.dart';

abstract class LatestRatesClient {
  Future<LatestRatesSnapshot> fetchLatest(String base);

  Future<Map<String, double>?> fetchYesterdayRates(String base) async => null;
}
