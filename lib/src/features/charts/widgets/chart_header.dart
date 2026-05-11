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
    super.key,
  });

  final String base;
  final String quote;
  final double? rate;
  final double? changePercent;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final baseCurrency = currencyByCode(base);
    final isPositive = (changePercent ?? 0) >= 0;
    final trendColor = isPositive ? AppTheme.trendUp : AppTheme.trendDown;
    final arrow = isPositive ? '↑' : '↓';

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
                  style: AppTheme.display.copyWith(fontSize: 28),
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
}
