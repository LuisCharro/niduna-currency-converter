import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';

class FavoriteRateText extends StatelessWidget {
  const FavoriteRateText({required this.rate, super.key});

  final double? rate;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Text(
      rate == null
          ? l10n(context).favoritesRateUnavailable
          : _formatRate(rate!),
      style: TextStyle(
        color: colors.text,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
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
