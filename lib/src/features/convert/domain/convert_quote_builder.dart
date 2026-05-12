import 'package:intl/intl.dart';

import '../../../core/currency/supported_currencies.dart';
import '../models/currency_quote.dart';
import 'latest_rates_snapshot.dart';

List<CurrencyQuote> buildQuotes({
  required LatestRatesSnapshot snapshot,
  required double amount,
  required int decimalPlaces,
  Iterable<String>? quoteCodes,
}) {
  final selectedCodes =
      quoteCodes?.where((code) => code != snapshot.base).toList() ??
      supportedCurrencies.map((currency) => currency.code).toList();

  final amountDigits = '#,##0.${'0' * decimalPlaces}';
  final amountFormat = NumberFormat(amountDigits, 'en');
  final rateFormat = NumberFormat('0.${'0' * decimalPlaces}', 'en');

  return selectedCodes
      .map(currencyByCode)
      .where((currency) => snapshot.rates.containsKey(currency.code))
      .map((currency) {
        final rate = snapshot.rates[currency.code]!;
        return CurrencyQuote(
          currency.symbol,
          currency.code,
          currency.name,
          amountFormat.format(amount * rate),
          '1 ${snapshot.base} = ${rateFormat.format(rate)} ${currency.code}',
        );
      })
      .toList(growable: false);
}
