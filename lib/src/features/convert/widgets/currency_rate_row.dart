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
  final VoidCallback onTap, onSetBase, onRemove, onToggleFavorite;
  final bool maxFavoritesReached;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppTheme.trendUp.withValues(alpha: .06)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTheme.rowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Row(
              children: <Widget>[
                Expanded(child: QuoteIdentity(quote: quote)),
                const SizedBox(width: 10),
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
      ),
    );
  }
}
