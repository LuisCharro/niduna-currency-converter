import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$base per 1 $quote',
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                if (rate != null)
                  Row(
                    children: <Widget>[
                      Text(
                        '${baseCurrency.symbol} ${rate!.toStringAsFixed(4)}',
                        style: AppTheme.body.copyWith(
                          fontSize: 18,
                          color: AppTheme.muted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (changePercent != null)
                        Text(
                          '$arrow ${changePercent!.abs().toStringAsFixed(2)}%',
                          style: AppTheme.body.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: trendColor,
                          ),
                        ),
                    ],
                  ),
                if (freshnessText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: AppTheme.subtle.withValues(alpha: .6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          freshnessText,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.subtle.withValues(alpha: .6),
                            fontWeight: FontWeight.w500,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.card,
                border: Border.all(color: AppTheme.border.withValues(alpha: .4)),
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
