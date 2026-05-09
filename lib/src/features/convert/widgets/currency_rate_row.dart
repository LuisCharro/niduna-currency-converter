import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';
import 'quote_identity.dart';
import 'quote_value.dart';

class CurrencyRateRow extends StatelessWidget {
  const CurrencyRateRow({
    required this.quote,
    required this.onRemove,
    super.key,
  });

  final CurrencyQuote quote;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .55)),
      ),
      child: Row(
        children: <Widget>[
          QuoteIdentity(quote: quote),
          const SizedBox(width: 14),
          Expanded(child: QuoteValue(quote: quote)),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Remove ${quote.code}',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: AppTheme.subtle, size: 18),
          ),
        ],
      ),
    );
  }
}
