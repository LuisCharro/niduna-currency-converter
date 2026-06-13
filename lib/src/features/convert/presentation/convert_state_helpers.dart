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
  return store.pairs.where((p) => p.base == base).map((p) => p.quote).toSet();
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
  FavoritesStore? favoritesStore,
) {
  if (snapshot == null || quotes.isEmpty) return;

  final fmtAmount = amount == amount.roundToDouble()
      ? '${amount.round()}'
      : amount.toStringAsFixed(2);

  final updatedLabel = RateFreshness.updatedLabel(
    rateDate: snapshot.date,
    savedAt: snapshot.savedAt,
  );

  final pairs = <WidgetPair>[];

  final favQuotes = favoritesStore != null
      ? favoritesStore.pairs
            .where((p) => p.base == base)
            .map((p) => p.quote)
            .toList()
      : <String>[];

  final sourceCodes = favQuotes.isNotEmpty
      ? favQuotes.take(3).toList()
      : const ['EUR', 'GBP', 'BTC'];

  for (final code in sourceCodes) {
    final quote = quotes.where((q) => q.code == code).firstOrNull;
    if (quote == null) continue;
    final trendStr = quote.trend?.name ?? 'none';
    final changeStr = quote.changePercent != null
        ? '${quote.changePercent!.abs().toStringAsFixed(2)}%'
        : '';
    pairs.add(
      WidgetPair(
        code: quote.code,
        symbol: quote.symbol,
        value: quote.amount,
        trend: trendStr,
        changePercent: changeStr,
      ),
    );
  }

  if (pairs.isEmpty) {
    final topQuote = quotes.first;
    pairs.add(
      WidgetPair(
        code: topQuote.code,
        symbol: topQuote.symbol,
        value: topQuote.amount,
      ),
    );
  }

  final widgetData = HomeWidgetData(
    baseCode: base,
    amountLabel: '$fmtAmount $base',
    updatedLabel: updatedLabel,
    pairs: pairs,
  );
  unawaited(HomeWidgetProvider().pushData(widgetData));
}

String formatUpdated(LatestRatesSnapshot snapshot) {
  return RateFreshness.updatedLabel(
    rateDate: snapshot.date,
    savedAt: snapshot.savedAt,
  );
}
