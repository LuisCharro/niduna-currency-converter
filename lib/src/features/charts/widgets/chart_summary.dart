import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

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
            value: high != null ? high!.toStringAsFixed(4) : '\u2014',
          ),
        ),
        Container(
          width: 1,
          height: 24,
          color: AppTheme.border.withValues(alpha: .3),
        ),
        Expanded(
          child: _SummaryItem(
            label: 'Low',
            value: low != null ? low!.toStringAsFixed(4) : '\u2014',
          ),
        ),
        Container(
          width: 1,
          height: 24,
          color: AppTheme.border.withValues(alpha: .3),
        ),
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
    return Column(
      children: <Widget>[
        Text(label, style: AppTheme.micro),
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
    );
  }
}
