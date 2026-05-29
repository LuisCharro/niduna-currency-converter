import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
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
    required this.onSwap,
    this.lastUpdated,
    super.key,
  });

  final String base;
  final String quote;
  final double? rate;
  final double? changePercent;
  final VoidCallback onSwap;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final baseCurrency = currencyByCode(base);
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ScreenTitle(chartsHeaderLabel(context)),
                const SizedBox(height: AppTheme.space1),
                Text('$base / $quote', style: AppTheme.pairTitleStyle(context)),
                const SizedBox(height: AppTheme.space2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    if (rate != null)
                      Text(
                        '${baseCurrency.symbol} ${formatChartValue(rate!)}',
                        style: AppTheme.metricValueStyle(context),
                      ),
                    if (changePercent != null) ...<Widget>[
                      const SizedBox(width: AppTheme.space3),
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
                  ],
                ),
                if (freshnessText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      freshnessText,
                      style: AppTheme.supportingTextStyle(context),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSwap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.of(context).card.withValues(alpha: .88)
                    : AppColors.of(context).card,
                border: Border.all(
                  color: AppColors.of(context).border.withValues(alpha: .28),
                ),
              ),
              child: Icon(
                Icons.swap_vert_rounded,
                color: AppColors.of(context).text,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String? _freshnessLabel(BuildContext context, DateTime? updated) {
    if (updated == null) return null;
    final diff = DateTime.now().difference(updated);
    if (diff.inMinutes < 1) return chartJustUpdated(context);
    if (diff.inMinutes < 60) {
      return chartUpdatedMinutesAgo(context, diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return chartUpdatedHoursAgo(context, diff.inHours);
    }
    return chartUpdatedDaysAgo(context, diff.inDays);
  }
}
