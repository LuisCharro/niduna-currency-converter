import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/currency_quote.dart';
import '../models/trend_direction.dart';

class QuoteValue extends StatelessWidget {
  const QuoteValue({required this.quote, super.key});

  final CurrencyQuote quote;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          '${quote.symbol} ${quote.amount}',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: colors.text,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            letterSpacing: -0.4,
          ),
        ),
        if (quote.rateLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              quote.rateLine,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: colors.muted.withValues(alpha: .82),
                letterSpacing: 0.2,
              ),
            ),
          ),
        if (quote.trend != null) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _TrendBadge(trend: quote.trend!, changePercent: quote.changePercent),
          ),
        ],
      ],
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend, this.changePercent});

  final TrendDirection trend;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final IconData icon;
    final Color color;

    switch (trend) {
      case TrendDirection.up:
        icon = Icons.arrow_upward;
        color = colors.trendUp;
      case TrendDirection.down:
        icon = Icons.arrow_downward;
        color = colors.trendDown;
      case TrendDirection.flat:
        icon = Icons.remove;
        color = colors.muted.withValues(alpha: .6);
    }

    final label = changePercent != null
        ? '${changePercent!.abs().toStringAsFixed(2)}%'
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 12, color: color),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}
