import 'package:flutter/material.dart';

import '../models/currency_quote.dart';
import 'currency_rate_row.dart';
import 'no_rates_card.dart';

class VisibleRatesSliver extends StatelessWidget {
  const VisibleRatesSliver({
    required this.quotes,
    required this.onRemove,
    super.key,
  });

  final List<CurrencyQuote> quotes;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return const SliverToBoxAdapter(child: NoRatesCard());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverList.separated(
        itemBuilder: (context, index) => CurrencyRateRow(
          quote: quotes[index],
          onRemove: () => onRemove(quotes[index].code),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: quotes.length,
      ),
    );
  }
}
