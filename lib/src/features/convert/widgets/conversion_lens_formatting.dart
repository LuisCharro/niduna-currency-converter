import 'package:intl/intl.dart';

import '../../../core/currency/amount_formatting.dart';
import '../../../core/currency/currency_decimals.dart';
import '../../../core/currency/supported_currencies.dart';

/// Fallback fiat decimal precision used for lens values when no explicit
/// user setting is threaded through (e.g. existing call sites/tests). Matches
/// the app's default `decimalPlaces` setting.
const int lensDefaultDecimalPlaces = 2;

int cryptoDigits(String code) {
  if (code == 'BTC') return 8;
  if (code == 'USDT' || code == 'USDC') return 2;
  if (code == 'DOGE') return 4;
  return 6;
}

String stripTrailingZeros(String formatted) {
  if (!formatted.contains('.')) return formatted;
  var result = formatted.replaceAll(RegExp(r'0+$'), '');
  if (result.endsWith('.')) result = result.substring(0, result.length - 1);
  return result;
}

String _fmtCrypto(double value, String code) => stripTrailingZeros(
  NumberFormat('#,##0.${'0' * cryptoDigits(code)}', 'en').format(value),
);

/// Formats a clean preset/target amount shown on the *input* side of a lens
/// row (e.g. the "Quick base amounts" left column, or a reverse-target
/// value): whole numbers such as 1, 10, 100, 1000 read as plain integers
/// instead of picking up spurious trailing zeros, while any genuinely
/// fractional value (e.g. a user-typed amount) falls back to the same
/// formatting the main rate list uses, honoring the user's [decimalPlaces]
/// setting so the lens always agrees with the list.
String formatLensValue(
  double value,
  String code, {
  int decimalPlaces = lensDefaultDecimalPlaces,
}) {
  if (isCryptoCurrency(code)) {
    return NumberFormat(
      '#,##0.${'0' * cryptoDigits(code)}',
      'en',
    ).format(value);
  }
  // Zero-decimal currencies (e.g. JPY) never show a fractional part.
  if (isZeroDecimalCurrency(code)) {
    return NumberFormat('#,##0', 'en').format(value);
  }
  // Clean whole-number presets (1, 10, 50, 100, 1000, ...) read as plain
  // integers rather than picking up spurious trailing zeros.
  if (value == value.roundToDouble()) {
    return NumberFormat('#,##0', 'en').format(value);
  }
  return formatConvertedAmount(value, code, decimalPlaces);
}

/// Formats a *computed* converted amount on a lens row (e.g. the "Quick base
/// amounts" right column, or a reverse-target's computed base amount) using
/// exactly the same formatter as the main rate list, so the two always agree,
/// honoring the user's [decimalPlaces] setting.
String formatLensConvertedAmount(
  double value,
  String code, {
  int decimalPlaces = lensDefaultDecimalPlaces,
}) => formatConvertedAmount(value, code, decimalPlaces);

String formatLensInput(double value) {
  if (value >= 100) return value.toStringAsFixed(0);
  if (value >= 10) return value.toStringAsFixed(2);
  return value.toStringAsFixed(3);
}

String formatHeroBase(double v, String c) => isCryptoCurrency(c)
    ? _fmtCrypto(v, c)
    : stripTrailingZeros(NumberFormat('#,##0.######', 'en').format(v));

String formatHeroConverted(
  double v,
  String c, {
  int decimalPlaces = lensDefaultDecimalPlaces,
}) {
  if (isCryptoCurrency(c)) return _fmtCrypto(v, c);
  if (isZeroDecimalCurrency(c)) return NumberFormat('#,##0', 'en').format(v);
  if (v >= 10) return formatConvertedAmount(v, c, decimalPlaces);
  return NumberFormat('#,##0.${'0' * (decimalPlaces + 1)}', 'en').format(v);
}

String formatLensRaw(double v, String c) => isCryptoCurrency(c)
    ? NumberFormat('0.${'0' * cryptoDigits(c)}', 'en').format(v)
    : NumberFormat('0.0000', 'en').format(v);
