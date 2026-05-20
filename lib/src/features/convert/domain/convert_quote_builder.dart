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
  final explicitCodes =
      quoteCodes?.where((code) => code != snapshot.base).toList() ??
      supportedCurrencies.map((currency) => currency.code).toList();

  // Auto-include crypto currencies that have rates in the snapshot,
  // regardless of user selection. Keeps BTC/ETH visible in the Convert tab.
  final cryptoCodes = supportedCryptoCurrencies
      .map((c) => c.code)
      .where((code) => snapshot.rates.containsKey(code));

  final selectedCodes = <String>{
    ...explicitCodes,
    ...cryptoCodes,
  }.toList();

  final amountDigits = '#,##0.${'0' * decimalPlaces}';
  final amountFormat = NumberFormat(amountDigits, 'en');
  final rateFormat = NumberFormat('0.${'0' * decimalPlaces}', 'en');

  return selectedCodes
      .map(currencyByCode)
      .where((currency) => snapshot.rates.containsKey(currency.code))
      .map((currency) {
        final rate = snapshot.rates[currency.code]!;
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
          isCryptoCurrency(currency.code) ? quoteAmount : amountFormat.format(amount * rate),
          isCryptoCurrency(currency.code)
              ? rateLine
              : '1 ${snapshot.base} = ${rateFormat.format(rate)} ${currency.code}',
        );
      })
      .toList(growable: false);
}

String _formatAmount(double value, String code, int decimalPlaces) {
  final digits = switch (code) {
    'BTC' => 8,
    'ETH' => 6,
    _ => decimalPlaces,
  };
  return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
}

String _formatRateLine({
  required String base,
  required String quote,
  required double rate,
  required int decimalPlaces,
}) {
  final digits = switch (quote) {
    'BTC' => 8,
    'ETH' => 6,
    _ => decimalPlaces,
  };
  final format = NumberFormat('0.${'0' * digits}', 'en');
  return '1 $base = ${format.format(rate)} $quote';
}
