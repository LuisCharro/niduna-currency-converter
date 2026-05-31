import '../../../core/rates/models/rates_result.dart';
import '../../../core/rates/rates_service.dart';
import '../domain/chart_repository.dart';

class RatesServiceChartRepository implements ChartRepository {
  const RatesServiceChartRepository(this._service);

  final RatesService _service;

  @override
  Future<HistoricalResult> getHistoricalRates({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) {
    return _service.getHistoricalRates(
      base: base,
      quote: quote,
      from: from,
      to: to,
    );
  }
}
