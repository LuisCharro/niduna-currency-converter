import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/screen_title.dart';
import 'chart_value_formatter.dart';

/// Compact chart masthead (D2-CHT-1).
class ChartHeader extends StatelessWidget {
  const ChartHeader({
    required this.base,
    required this.quote,
    required this.rate,
    required this.changePercent,
    this.lastUpdated,
    super.key,
  });

  final String base;
  final String quote;
  final double? rate;
  final double? changePercent;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final isPositive = (changePercent ?? 0) >= 0;
    final trendColor = isPositive
        ? AppColors.of(context).trendUp
        : AppColors.of(context).trendDown;
    final arrow = isPositive ? '↑' : '↓';
    final freshnessText = _freshnessLabel(context, lastUpdated);

    return Padding(
      padding: AppTheme.pageInsets.copyWith(
        top: AppTheme.space1,
        bottom: AppTheme.space2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ScreenTitle(chartsHeaderLabel(context)),
              if (freshnessText != null) ...<Widget>[
                const SizedBox(width: AppTheme.space2),
                Expanded(
                  child: Text(
                    freshnessText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTheme.supportingTextStyle(context),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            '$base / $quote',
            style: AppTheme.pairTitleStyle(context),
          ),
          const SizedBox(height: AppTheme.space2),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppTheme.space3,
              runSpacing: AppTheme.space1,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (rate != null)
                  Text(
                    '1 $base = ${formatChartValue(rate!)} $quote',
                    style: AppTheme.metricValueStyle(context),
                  ),
                if (changePercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$arrow ${changePercent!.abs().toStringAsFixed(2)}%',
                      style: AppTheme.metricDelta.copyWith(
                        color: trendColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _freshnessLabel(BuildContext context, DateTime? updated) {
    if (updated == null) return null;
    return chartDailyDataLabel(context, updated);
  }
}
