import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';
import 'currency_rate_row.dart';
import 'no_rates_card.dart';

class VisibleRatesList extends StatelessWidget {
  const VisibleRatesList({
    required this.quotes,
    required this.activeCode,
    required this.onSelectCode,
    required this.onSetBase,
    required this.onRemove,
    required this.onToggleFavorite,
    this.maxFavoritesReached = false,
    super.key,
  });

  final List<CurrencyQuote> quotes;
  final String? activeCode;
  final ValueChanged<String> onSelectCode;
  final ValueChanged<String> onSetBase;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onToggleFavorite;
  final bool maxFavoritesReached;

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16),
        child: NoRatesCard(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemBuilder: (context, index) => CurrencyRateRow(
        quote: quotes[index],
        isActive: activeCode == quotes[index].code,
        onTap: () => onSelectCode(quotes[index].code),
        onSetBase: () => onSetBase(quotes[index].code),
        onRemove: () => onRemove(quotes[index].code),
        onToggleFavorite: () => onToggleFavorite(quotes[index].code),
        maxFavoritesReached: maxFavoritesReached,
      ),
      separatorBuilder: (context, index) => Divider(
        color: AppTheme.border.withValues(alpha: .4),
        height: 1,
      ),
      itemCount: quotes.length,
    );
  }
}
