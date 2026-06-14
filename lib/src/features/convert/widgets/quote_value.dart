import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/currency_quote.dart';
import '../models/trend_direction.dart';
import 'trend_badge.dart';

class QuoteValue extends StatelessWidget {
  const QuoteValue({required this.quote, super.key});

  final CurrencyQuote quote;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // Hide the badge when there is no meaningful move: a flat trend, or a
    // change that rounds to 0.00% (e.g. on weekends when ECB/Frankfurter
    // returns the same prior business day for both today and yesterday).
    final pct = quote.changePercent;
    final showTrend = quote.trend != null &&
        quote.trend != TrendDirection.flat &&
        (pct == null || pct.abs() >= 0.005);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (showTrend) ...<Widget>[
              TrendBadge(
                trend: quote.trend!,
                changePercent: quote.changePercent,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '${quote.symbol} ${quote.amount}',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.text,
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
                letterSpacing: -0.4,
              ),
            ),
          ],
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
      ],
    );
  }
}
