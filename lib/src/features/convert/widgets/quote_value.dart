import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';

class QuoteValue extends StatelessWidget {
  const QuoteValue({required this.quote, this.isActive = false, super.key});

  final CurrencyQuote quote;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? AppTheme.trendUp : AppTheme.greenBadge;
    final textColor = isActive ? Colors.white : AppTheme.greenBadgeText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Text(
            '${quote.symbol} ${quote.amount}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textColor,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
        if (quote.rateLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              quote.rateLine,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.muted,
                letterSpacing: 0.2,
              ),
            ),
          ),
      ],
    );
  }
}
