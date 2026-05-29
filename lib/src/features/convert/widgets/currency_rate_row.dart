import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';
import 'quote_identity.dart';
import 'quote_value.dart';

class CurrencyRateRow extends StatelessWidget {
  const CurrencyRateRow({
    required this.quote,
    super.key,
  });

  final CurrencyQuote quote;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTheme.rowMinHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.of(context).border.withValues(alpha: .32),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: CurrencyFlagIcon(
                    code: quote.code,
                    symbol: quote.symbol,
                    radius: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: QuoteIdentity(quote: quote)),
              const SizedBox(width: 12),
              QuoteValue(quote: quote),
            ],
          ),
        ),
      ),
    );
  }
}
