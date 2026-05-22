import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/designed_state_panel.dart';
import '../models/currency_quote.dart';
import 'currency_rate_row.dart';

class VisibleRatesList extends StatelessWidget {
  const VisibleRatesList({
    required this.quotes,
    required this.activeCode,
    required this.onSelectCode,
    required this.onSetBase,
    required this.onRemove,
    required this.onToggleFavorite,
    this.maxFavoritesReached = false,
    this.onRefresh,
    super.key,
  });

  final List<CurrencyQuote> quotes;
  final String? activeCode;
  final ValueChanged<String> onSelectCode;
  final ValueChanged<String> onSetBase;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onToggleFavorite;
  final bool maxFavoritesReached;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return SingleChildScrollView(
        padding: AppTheme.pageInsets,
        child: DesignedStatePanel(
          icon: Icons.currency_exchange_rounded,
          title: 'No rates on the ledger yet',
          subtitle: 'Pull to refresh or tap sync when you are back online',
          actionLabel: 'Refresh',
          onAction: onRefresh != null ? () => onRefresh!() : null,
        ),
      );
    }

    final list = ListView.separated(
      key: const Key('convert_rates_list'),
      padding: AppTheme.pageInsets.copyWith(bottom: AppTheme.space2),
      itemBuilder: (context, index) => CurrencyRateRow(
        quote: quotes[index],
        isActive: activeCode == quotes[index].code,
        onTap: () => onSelectCode(quotes[index].code),
        onSetBase: () => onSetBase(quotes[index].code),
        onRemove: () => onRemove(quotes[index].code),
        onToggleFavorite: () => onToggleFavorite(quotes[index].code),
        maxFavoritesReached: maxFavoritesReached,
      ),
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(left: 58),
        child: Divider(
          color: AppTheme.border.withValues(alpha: .15),
          height: .5,
        ),
      ),
      itemCount: quotes.length,
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppTheme.trendUp,
        backgroundColor: AppTheme.card,
        edgeOffset: 20,
        child: list,
      );
    }
    return list;
  }
}
