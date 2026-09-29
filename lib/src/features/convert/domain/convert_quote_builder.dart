import 'package:intl/intl.dart';

import '../../../core/currency/amount_formatting.dart';
import '../../../core/currency/supported_currencies.dart';
import '../models/currency_quote.dart';
import 'latest_rates_snapshot.dart';

List<CurrencyQuote> buildQuotes({
  required LatestRatesSnapshot snapshot,
  required double amount,
  required int decimalPlaces,
  Iterable<String>? quoteCodes,
}) {
  final explicitCodes =
      quoteCodes?.where((code) => code != snapshot.base).toList() ??
      supportedCurrencies.map((currency) => currency.code).toList();

  final rateFormat = NumberFormat('0.${'0' * decimalPlaces}', 'en');

  return explicitCodes
      .map(currencyByCode)
      .where((currency) => snapshot.rates.containsKey(currency.code))
      .map((currency) {
        final rate = snapshot.rates[currency.code]!;
        final previousRate = snapshot.previousRates?[currency.code];
        final quoteAmount = _formatAmount(
          amount * rate,
          currency.code,
          decimalPlaces,
        );
        final rateLine = _formatRateLine(
          base: snapshot.base,
          quote: currency.code,
          rate: rate,
          decimalPlaces: decimalPlaces,
        );
        return CurrencyQuote(
          currency.symbol,
          currency.code,
          currency.name,
          quoteAmount,
          isCryptoCurrency(currency.code)
              ? rateLine
              : '1 ${snapshot.base} = ${rateFormat.format(rate)} ${currency.code}',
          rate: rate,
          previousRate: previousRate,
        );
      })
      .toList(growable: false);
}

String _formatAmount(double value, String code, int decimalPlaces) =>
    formatConvertedAmount(value, code, decimalPlaces);

String _formatRateLine({
  required String base,
  required String quote,
  required double rate,
  required int decimalPlaces,
}) {
  final digits = isCryptoCurrency(quote)
      ? cryptoAmountDigits(quote)
      : decimalPlaces;
  final format = NumberFormat('0.${'0' * digits}', 'en');
  return '1 $base = ${format.format(rate)} $quote';
}
