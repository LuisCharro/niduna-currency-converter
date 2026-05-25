import '../../convert/domain/latest_rates_snapshot.dart';
import 'favorite_pair.dart';

double? rateForFavoritePair({
  required FavoritePair pair,
  required LatestRatesSnapshot? snapshot,
}) {
  final rates = snapshot?.rates;
  final snapBase = snapshot?.base;
  if (rates == null || snapBase == null) return null;

  if (snapBase == pair.base) return rates[pair.quote];

  if (snapBase == pair.quote) {
    final baseRate = rates[pair.base];
    if (baseRate == null || baseRate == 0) return null;
    return 1.0 / baseRate;
  }

  final baseRate = rates[pair.base];
  final quoteRate = rates[pair.quote];
  if (baseRate == null || quoteRate == null || baseRate == 0) return null;
  return quoteRate / baseRate;
}
