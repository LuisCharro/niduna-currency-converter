import '../../convert/domain/latest_rates_snapshot.dart';
import 'favorite_pair.dart';

/// Current rate for a favorite pair, derived from the snapshot's latest rates.
double? rateForFavoritePair({
  required FavoritePair pair,
  required LatestRatesSnapshot? snapshot,
}) =>
    _rateFrom(rates: snapshot?.rates, base: snapshot?.base, pair: pair);

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
