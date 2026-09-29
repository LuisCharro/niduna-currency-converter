import 'package:intl/intl.dart';

import 'currency_decimals.dart';
import 'supported_currencies.dart';

/// Decimal digits used for a crypto amount, tuned per asset so tiny-value
/// coins (BTC) and stable/whole coins (USDT, DOGE) read sensibly.
int cryptoAmountDigits(String code) {
  if (code == 'BTC') return 8;
  if (code == 'USDT' || code == 'USDC') return 2;
  if (code == 'DOGE') return 4;
  return 6;
}

/// Formats a converted amount in [code] the same way the main Convert rate
/// list does: crypto currencies use [cryptoAmountDigits], fiat currencies use
/// [decimalPlaces] unless [code] is a zero-decimal currency (see
/// `currency_decimals.dart`), in which case it always renders with 0
/// decimals. This is the single source of truth for "converted amount"
/// formatting — reused by the rate list, the share card and the Conversion
/// Lens so they always agree.
String formatConvertedAmount(double value, String code, int decimalPlaces) {
  final digits = isCryptoCurrency(code)
      ? cryptoAmountDigits(code)
      : decimalsForCurrency(code, decimalPlaces);
  final pattern = digits == 0 ? '#,##0' : '#,##0.${'0' * digits}';
  return NumberFormat(pattern, 'en').format(value);
}
