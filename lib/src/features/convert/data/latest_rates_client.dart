import '../domain/latest_rates_snapshot.dart';

abstract class LatestRatesClient {
  Future<LatestRatesSnapshot> fetchLatest(String base);
}
