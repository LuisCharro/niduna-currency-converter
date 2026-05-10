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
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: isActive
                  ? AppTheme.primary.withValues(alpha: .5)
                  : AppTheme.border.withValues(alpha: .55),
            ),
          ),
          child: Row(
            children: <Widget>[
              QuoteIdentity(quote: quote),
              const SizedBox(width: 14),
              Expanded(child: QuoteValue(quote: quote)),
              const SizedBox(width: 6),
              if (isActive)
                IconButton(
                  tooltip: 'Set ${quote.code} as base',
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  onPressed: onSetBase,
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
              IconButton(
                tooltip: 'Remove ${quote.code}',
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: AppTheme.subtle, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
