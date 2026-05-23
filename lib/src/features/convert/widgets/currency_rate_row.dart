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
    final colors = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTheme.rowMinHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(
            children: <Widget>[
              Container(
                width: 3,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuoteIdentity(quote: quote),
              ),
              const SizedBox(width: 10),
              QuoteValue(quote: quote),
            ],
          ),
        ),
      ),
    );
  }
}
