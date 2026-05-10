import 'models/rates_snapshot.dart';

abstract class RatesCache {
  Future<RatesSnapshot?> readLatest(String base);
  Future<void> writeLatest(RatesSnapshot snapshot);
  Future<void> invalidateLatest(String base);

  Future<HistoricalSnapshot?> readHistorical({
    required String base,
    required String quote,
  });

  Future<void> writeHistorical(HistoricalSnapshot snapshot);

  Future<void> invalidateHistorical({
    required String base,
    required String quote,
  });

  Future<void> clear();
}
