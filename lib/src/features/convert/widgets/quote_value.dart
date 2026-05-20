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
        Text(
          '${quote.symbol} ${quote.amount}',
          style: TextStyle(
            fontSize: isActive ? 19 : 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.text,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            letterSpacing: -0.2,
          ),
        ),
        if (quote.rateLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              quote.rateLine,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted.withValues(alpha: .88),
                letterSpacing: 0.2,
              ),
            ),
          ),
      ],
    );
  }
}
