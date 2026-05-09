import 'package:intl/intl.dart';

import '../../../core/currency/supported_currencies.dart';
import '../models/currency_quote.dart';
import 'latest_rates_snapshot.dart';

final NumberFormat _amountFormat = NumberFormat('#,##0.00', 'en');
final NumberFormat _rateFormat = NumberFormat('0.0000', 'en');

List<CurrencyQuote> buildQuotes({
  required LatestRatesSnapshot snapshot,
  required double amount,
  Iterable<String>? quoteCodes,
}) {
  final selectedCodes =
      quoteCodes?.where((code) => code != snapshot.base).toList() ??
      supportedCurrencies.map((currency) => currency.code).toList();

  return selectedCodes
      .map(currencyByCode)
      .where((currency) => snapshot.rates.containsKey(currency.code))
      .map((currency) {
        final rate = snapshot.rates[currency.code]!;
        return CurrencyQuote(
          currency.symbol,
          currency.code,
          currency.name,
          _amountFormat.format(amount * rate),
          '1 ${snapshot.base} = ${_rateFormat.format(rate)} ${currency.code}',
        );
      })
      .toList(growable: false);
}
