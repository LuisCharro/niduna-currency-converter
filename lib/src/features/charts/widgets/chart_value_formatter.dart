import 'dart:math' as math;

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

String formatChartCompactValue(double value) {
  final absValue = value.abs();
  if (absValue == 0) return '0';

  const significantDigits = 3;
  final exponent = (math.log(absValue) / math.ln10).floor();
  final scale = math.pow(10, exponent - significantDigits + 1).toDouble();
  final compactValue = (value / scale).round() * scale;
  final fractionDigits = math.max(0, significantDigits - exponent - 1);

  if (fractionDigits == 0) {
    return NumberFormat('#,##0', 'en').format(compactValue);
  }
  return NumberFormat(
    '#,##0.${'0' * fractionDigits}',
    'en',
  ).format(compactValue);
}
