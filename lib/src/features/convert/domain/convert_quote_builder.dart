import 'package:intl/intl.dart';

import '../../../core/currency/supported_currencies.dart';
import '../models/currency_quote.dart';
import 'latest_rates_snapshot.dart';

List<CurrencyQuote> buildQuotes({
  required LatestRatesSnapshot snapshot,
  required double amount,
  required int decimalPlaces,
  Iterable<String>? quoteCodes,
  Set<String> excludeCodes = const <String>{},
}) {
  final explicitCodes =
      quoteCodes?.where((code) => code != snapshot.base).toList() ??
      supportedCurrencies.map((currency) => currency.code).toList();

  // Auto-include crypto currencies that have rates in the snapshot,
  // unless the user explicitly hid them via swipe-to-hide.
  final cryptoCodes = supportedCryptoCurrencies
      .map((c) => c.code)
      .where((code) => snapshot.rates.containsKey(code))
      .where((code) => !excludeCodes.contains(code));

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
          rate: rate,
        );
      })
      .toList(growable: false);
}

int _cryptoDigits(String code) {
  if (code == 'BTC') return 8;
  if (code == 'USDT' || code == 'USDC') return 2;
  if (code == 'DOGE') return 4;
  return 6;
}

String _formatAmount(double value, String code, int decimalPlaces) {
  final digits = isCryptoCurrency(code) ? _cryptoDigits(code) : decimalPlaces;
  return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
}

String _formatRateLine({
  required String base,
  required String quote,
  required double rate,
  required int decimalPlaces,
}) {
  final digits = isCryptoCurrency(quote) ? _cryptoDigits(quote) : decimalPlaces;
  final format = NumberFormat('0.${'0' * digits}', 'en');
  return '1 $base = ${format.format(rate)} $quote';
}
