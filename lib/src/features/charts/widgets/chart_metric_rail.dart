import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'chart_value_formatter.dart';

/// Flat divider-separated metric row (D2-CHT-6).
class ChartMetricRail extends StatelessWidget {
  const ChartMetricRail({
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
    final changeColor = isPositive ? AppColors.of(context).trendUp : AppColors.of(context).trendDown;
    final changeText = changePercent != null
        ? '${isPositive ? '+' : ''}${changePercent!.toStringAsFixed(2)}%'
        : '—';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.of(context).border.withValues(alpha: .12)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _MetricCell(
                label: metricHigh(context),
                value: high != null ? formatChartValue(high!) : '—',
              ),
            ),
            _railDivider(context),
            Expanded(
              child: _MetricCell(
                label: metricLow(context),
                value: low != null ? formatChartValue(low!) : '—',
              ),
            ),
            _railDivider(context),
            Expanded(
              child: _MetricCell(
                label: metricChange(context),
                value: changeText,
                valueColor: changePercent != null ? changeColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _railDivider(BuildContext context) => Container(
    width: 1,
    height: 32,
    color: AppColors.of(context).border.withValues(alpha: .12),
  );
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: AppTheme.sectionLabelStyle(context)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.caption.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.of(context).text,
            ),
          ),
        ],
      ),
    );
  }
}
