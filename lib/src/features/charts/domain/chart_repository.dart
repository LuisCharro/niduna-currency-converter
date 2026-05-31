import '../../../core/rates/models/rates_result.dart';

abstract class ChartRepository {
  Future<HistoricalResult> getHistoricalRates({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  });
}
