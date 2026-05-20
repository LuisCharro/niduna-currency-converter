import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import 'chart_value_formatter.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Charts',
                  style: AppTheme.micro.copyWith(
                    color: AppTheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$base / $quote',
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    if (rate != null)
                      Text(
                        '${baseCurrency.symbol} ${formatChartValue(rate!)}',
                        style: AppTheme.body.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                    if (changePercent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$arrow ${changePercent!.abs().toStringAsFixed(2)}%',
                          style: AppTheme.caption.copyWith(
                            color: trendColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                if (freshnessText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          freshnessText,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSwap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.card.withValues(alpha: .88),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: .22),
                ),
                boxShadow: AppTheme.subtleShadow,
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
    if (diff.inMinutes < 60) {
      return 'Updated ${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return 'Updated ${diff.inHours}h ago';
    }
    return 'Updated ${diff.inDays}d ago';
  }
}
