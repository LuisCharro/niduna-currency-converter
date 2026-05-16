import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class ChartTouchOverlay extends StatelessWidget {
  const ChartTouchOverlay({
    required this.date,
    required this.value,
    required this.baseValue,
    required this.lineColor,
    super.key,
  });

  final DateTime date;
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
    final trendColor = isPositiveChange ? AppTheme.trendUp : AppTheme.trendDown;
    final arrow = isPositiveChange ? '\u2191' : '\u2193';
    final sign = isPositiveChange ? '+' : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor.withValues(alpha: .14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.border.withValues(alpha: .12),
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
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: lineColor,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value.toStringAsFixed(4),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
                fontFamily: 'Fraunces',
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$arrow ${changePercent.abs().toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: trendColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$sign${absoluteChange.abs().toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
