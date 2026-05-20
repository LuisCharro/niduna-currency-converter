import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'chart_value_formatter.dart';

class ChartSummary extends StatelessWidget {
  const ChartSummary({
    required this.high,
    required this.low,
    required this.changePercent,
    super.key,
  });

  final double? high;
  final double? low;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    final isPositive = (changePercent ?? 0) >= 0;
    final changeColor = isPositive ? AppTheme.trendUp : AppTheme.trendDown;

    return Row(
      children: <Widget>[
        Expanded(
          child: _SummaryItem(
            label: 'High',
            value: high != null ? formatChartValue(high!) : '\u2014',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryItem(
            label: 'Low',
            value: low != null ? formatChartValue(low!) : '\u2014',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryItem(
            label: 'Change',
            value: changePercent != null
                ? '${isPositive ? '+' : ''}${changePercent!.toStringAsFixed(2)}%'
                : '\u2014',
            valueColor: changePercent != null ? changeColor : null,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.container.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border.withValues(alpha: .08)),
      ),
      child: Column(
        children: <Widget>[
          Text(label, style: AppTheme.micro.copyWith(color: AppTheme.muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppTheme.text,
            ),
          ),
        ],
      ),
    );
  }
}
