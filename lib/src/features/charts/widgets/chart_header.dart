import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
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
    final trendColor = isPositive ? AppTheme.trendUp : AppTheme.trendDown;
    final arrow = isPositive ? '↑' : '↓';
    final freshnessText = _freshnessLabel(lastUpdated);

    return Padding(
      padding: AppTheme.pageInsets.copyWith(
        top: AppTheme.space2,
        bottom: AppTheme.space2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CHARTS',
                  style: AppTheme.sectionLabel.copyWith(
                    color: AppTheme.trendUp,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: AppTheme.space1),
                Text('$base / $quote', style: AppTheme.pairTitleFraunces),
                const SizedBox(height: AppTheme.space2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    if (rate != null)
                      Text(
                        '${baseCurrency.symbol} ${formatChartValue(rate!)}',
                        style: AppTheme.metricValue,
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
                          style: AppTheme.metricDelta.copyWith(color: trendColor),
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
                      style: AppTheme.caption.copyWith(color: AppTheme.muted),
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
                color: AppTheme.card.withValues(alpha: .88),
                border: Border.all(color: AppTheme.instrumentBorder(.2)),
              ),
              child: Icon(
                Icons.swap_vert_rounded,
                color: AppTheme.text,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String? _freshnessLabel(DateTime? updated) {
    if (updated == null) return null;
    final diff = DateTime.now().difference(updated);
    if (diff.inMinutes < 1) return 'Just updated';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }
}
