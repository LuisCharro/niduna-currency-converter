import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';

class QuoteValue extends StatelessWidget {
  const QuoteValue({required this.quote, this.isActive = false, super.key});

  final CurrencyQuote quote;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.trendUp
                : AppTheme.trendUp.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${quote.symbol} ${quote.amount}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppTheme.trendUp,
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        if (quote.rateLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              quote.rateLine,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.subtle.withValues(alpha: .6),
              ),
            ),
          ),
      ],
    );
  }
}
