import 'dart:async';

import '../../../core/widget/home_widget_provider.dart';
import '../../../core/widget/widget_data.dart';
import '../domain/latest_rates_snapshot.dart';
import '../domain/rate_freshness.dart';
import '../models/currency_quote.dart';
import '../domain/convert_quote_builder.dart';
import '../../favorites/data/favorites_store.dart';

Set<String> favoriteQuotesForBase(FavoritesStore? store, String base) {
  if (store == null) return <String>{};
  return store.pairs
      .where((p) => p.base == base)
      .map((p) => p.quote)
      .toSet();
}

List<CurrencyQuote> buildCurrencyQuotes({
  required LatestRatesSnapshot snapshot,
  required double amount,
  required int decimalPlaces,
  required List<String> selectedCodes,
  required Set<String> hiddenCryptoCodes,
  required Set<String> favQuotes,
}) {
  final rawQuotes = buildQuotes(
    snapshot: snapshot,
    amount: amount,
    decimalPlaces: decimalPlaces,
    quoteCodes: selectedCodes,
    excludeCodes: hiddenCryptoCodes,
  );
  return rawQuotes.map((q) {
    final isFav = favQuotes.contains(q.code);
    return CurrencyQuote(
      q.symbol,
      q.code,
      q.name,
      q.amount,
      q.rateLine,
      rate: q.rate,
      favorite: isFav,
    );
  }).toList();
}

void pushHomeWidgetData(
  String base,
  double amount,
  List<CurrencyQuote> quotes,
  LatestRatesSnapshot? snapshot,
) {
  if (snapshot == null || quotes.isEmpty) return;
  final topQuote = quotes.first;
  final widgetData = HomeWidgetData(
    baseCode: base,
    quoteCode: topQuote.code,
    rate: topQuote.rate,
    amount: amount,
    convertedAmount: topQuote.amount,
    updatedAt: snapshot.date?.toString().substring(0, 10) ?? '',
  );
  unawaited(HomeWidgetProvider().pushData(widgetData));
}

String formatUpdated(LatestRatesSnapshot snapshot) {
  return RateFreshness.updatedLabel(
    rateDate: snapshot.date,
    savedAt: snapshot.savedAt,
  );
}
