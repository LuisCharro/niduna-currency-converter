import 'models/rates_snapshot.dart';

abstract class RatesClient {
  Future<RatesSnapshot> fetchLatest(String base);

  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  });
}

class RatesClientException implements Exception {
  const RatesClientException(this.message);
  final String message;

  @override
  String toString() => message;
}
