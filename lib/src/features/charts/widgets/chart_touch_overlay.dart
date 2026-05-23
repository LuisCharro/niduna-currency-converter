import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import 'chart_theme_text.dart';
import 'chart_value_formatter.dart';

class ChartTouchOverlay extends StatelessWidget {
  const ChartTouchOverlay({
    required this.date,
    required this.currencySymbol,
    required this.value,
    required this.baseValue,
    required this.lineColor,
    super.key,
  });

  final DateTime date;
  final String currencySymbol;
  final double value;
  final double baseValue;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final changePercent = baseValue != 0
        ? ((value - baseValue) / baseValue.abs()) * 100
        : 0.0;
    final absoluteChange = value - baseValue;
    final isPositiveChange = changePercent >= 0;
    final trendColor = isPositiveChange ? AppColors.of(context).trendUp : AppColors.of(context).trendDown;
    final arrow = isPositiveChange ? '\u2191' : '\u2193';
    final sign = isPositiveChange ? '+' : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.of(context).card.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor.withValues(alpha: .14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.of(context).border.withValues(alpha: .12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              DateFormat('EEE d MMM').format(date).toUpperCase(),
              style: ChartThemeText.micro(context, color: lineColor),
            ),
            const SizedBox(height: 3),
            Text(
              '$currencySymbol ${formatChartValue(value)}',
              style: ChartThemeText.frauncesValue(context),
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$arrow ${changePercent.abs().toStringAsFixed(2)}%',
                  style: ChartThemeText.caption(context, color: trendColor).copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$currencySymbol $sign${formatChartValue(absoluteChange.abs())}',
                  style: ChartThemeText.caption(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
