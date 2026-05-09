import 'package:flutter/material.dart';

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
    super.key,
  });

  final List<CurrencyQuote> quotes;
  final String? activeCode;
  final ValueChanged<String> onSelectCode;
  final ValueChanged<String> onSetBase;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16),
        child: NoRatesCard(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemBuilder: (context, index) => CurrencyRateRow(
        quote: quotes[index],
        isActive: activeCode == quotes[index].code,
        onTap: () => onSelectCode(quotes[index].code),
        onSetBase: () => onSetBase(quotes[index].code),
        onRemove: () => onRemove(quotes[index].code),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: quotes.length,
    );
  }
}
