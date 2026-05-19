import 'package:intl/intl.dart';

String formatChartValue(double value) {
  final absValue = value.abs();
  final digits = switch (absValue) {
    >= 1000 => 2,
    >= 1 => 4,
    >= 0.0001 => 6,
    >= 0.000001 => 8,
    _ => 10,
  };
  return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
}
