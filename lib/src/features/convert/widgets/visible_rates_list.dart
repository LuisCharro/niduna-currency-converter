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
      return const SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16),
        child: NoRatesCard(),
      );
    }

    final list = ListView.separated(
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
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(left: 52),
        child: Divider(
          color: AppTheme.border.withValues(alpha: .2),
          height: .5,
          indent: 0,
        ),
      ),
      itemCount: quotes.length,
    );

    if (onRefresh != null) {
      return Stack(
        children: <Widget>[
          RefreshIndicator(
            onRefresh: onRefresh!,
            color: AppTheme.trendUp,
            backgroundColor: AppTheme.card,
            edgeOffset: 20,
            child: list,
          ),
          Positioned(
            left: 18,
            top: 0,
            bottom: 100,
            width: 1.2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x406F8C49),
                    const Color(0x086F8C49),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: <Widget>[
        list,
        Positioned(
          left: 18,
          top: 0,
          bottom: 100,
          width: 1.2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              colors: [
                const Color(0x406F8C49),
                const Color(0x086F8C49),
              ],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }
}
