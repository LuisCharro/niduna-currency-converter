import 'package:currency_converter/src/features/charts/widgets/chart_value_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'formatChartValue keeps useful precision for small crypto-style rates',
    () {
      expect(formatChartValue(0.00001984), '0.00001984');
    },
  );

  test('formatChartValue keeps useful precision for small deltas', () {
    expect(formatChartValue(0.00000042), '0.0000004200');
  });

  test(
    'formatChartValue keeps readable precision for large fiat-style rates',
    () {
      expect(formatChartValue(1234.5678), '1,234.57');
    },
  );
}
