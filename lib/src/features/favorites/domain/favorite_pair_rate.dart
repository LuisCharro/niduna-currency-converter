import 'package:intl/intl.dart' as intl;

import '../../convert/domain/latest_rates_snapshot.dart';
import 'favorite_pair.dart';

/// Current rate for a favorite pair, derived from the snapshot's latest rates.
double? rateForFavoritePair({
  required FavoritePair pair,
  required LatestRatesSnapshot? snapshot,
}) => _rateFrom(rates: snapshot?.rates, base: snapshot?.base, pair: pair);

/// Prior business day rate for a favorite pair, for the day-over-day trend.
double? previousRateForFavoritePair({
  required FavoritePair pair,
  required LatestRatesSnapshot? snapshot,
}) =>
    _rateFrom(rates: snapshot?.previousRates, base: snapshot?.base, pair: pair);

double? _rateFrom({
  required Map<String, double>? rates,
  required String? base,
  required FavoritePair pair,
}) {
  if (rates == null || base == null) return null;

  if (base == pair.base) return rates[pair.quote];

  if (base == pair.quote) {
    final baseRate = rates[pair.base];
    if (baseRate == null || baseRate == 0) return null;
    return 1.0 / baseRate;
  }

  final baseRate = rates[pair.base];
  final quoteRate = rates[pair.quote];
  if (baseRate == null || quoteRate == null || baseRate == 0) return null;
  return quoteRate / baseRate;
}

/// "1 / rate", i.e. how much [FavoritePair.base] one unit of
/// [FavoritePair.quote] buys. Null when [rate] is null or zero (no reverse
/// line is shown then).
double? reverseRateFor(double? rate) {
  if (rate == null || rate == 0) return null;
  return 1.0 / rate;
}

/// Smart-decimal formatting shared by the hero rate, the row value pill and
/// the reverse-rate line: `>=100` -> 2 decimals, `>=0.1` -> 4 (always shown,
/// e.g. "1.1370"), else up to 8 significant decimals.
String formatFavoriteRate(double value) {
  if (value == 0) return '0';
  final abs = value.abs();
  if (abs >= 100) {
    final formatted = intl.NumberFormat.decimalPatternDigits(
      decimalDigits: 2,
    ).format(value);
    // A whole number reads more naturally without ".00" — a large crypto
    // reverse rate is "83,195", not "83,195.00".
    return formatted.replaceFirst(RegExp(r'\.00$'), '');
  }
  if (abs >= 0.1) {
    return intl.NumberFormat.decimalPatternDigits(
      decimalDigits: 4,
    ).format(value);
  }
  final formatted = intl.NumberFormat.decimalPatternDigits(
    decimalDigits: 8,
  ).format(value);
  final trimmed = formatted.replaceFirst(RegExp(r'0+$'), '');
  return trimmed.endsWith('.')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}
