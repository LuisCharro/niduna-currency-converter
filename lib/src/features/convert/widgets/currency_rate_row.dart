import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';
import 'quote_identity.dart';
import 'quote_value.dart';

class CurrencyRateRow extends StatelessWidget {
  const CurrencyRateRow({
    required this.quote,
    required this.isActive,
    required this.onTap,
    required this.onSetBase,
    required this.onRemove,
    required this.onToggleFavorite,
    this.maxFavoritesReached = false,
    super.key,
  });

  final CurrencyQuote quote;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onSetBase;
  final VoidCallback onRemove;
  final VoidCallback onToggleFavorite;
  final bool maxFavoritesReached;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: <Widget>[
              QuoteIdentity(quote: quote),
              const Spacer(),
              QuoteValue(quote: quote, isActive: isActive),
              if (isActive) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSetBase,
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
