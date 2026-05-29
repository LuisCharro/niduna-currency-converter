import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../shared/widgets/value_pill.dart';

class FavoriteRateText extends StatelessWidget {
  const FavoriteRateText({required this.rate, super.key});

  final double? rate;

  @override
  Widget build(BuildContext context) {
    return ValuePill(
      text: rate == null ? '\u2014' : _formatRate(rate!),
    );
  }

  String _formatRate(double value) {
    if (value == 0) return '0';
    final abs = value.abs();
    final decimals = abs >= 100
        ? 2
        : abs >= .01
        ? 4
        : 8;
    return intl.NumberFormat.decimalPatternDigits(
      decimalDigits: decimals,
    ).format(value);
  }
}
