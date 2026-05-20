import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          ? AppTheme.trendUp.withValues(alpha: .055)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isActive) {
            onTap();
            return;
          }
          HapticFeedback.selectionClick();
          onSetBase();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTheme.rowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: Row(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 3,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary.withValues(alpha: .9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuoteIdentity(quote: quote, isActive: isActive),
                ),
                const SizedBox(width: 10),
                QuoteValue(quote: quote, isActive: isActive),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
