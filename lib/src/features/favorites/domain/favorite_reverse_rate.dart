import 'favorite_pair.dart';
import 'favorite_pair_rate.dart';

/// "1 QUOTE = X.XXXX BASE" — the reverse-rate supporting line shown under a
/// pair's title (hero and rows). Null when the forward [rate] itself is
/// missing: per spec, a missing rate means no reverse line at all rather
/// than a "—" placeholder.
String? favoriteReverseRateLine({
  required FavoritePair pair,
  required double? rate,
}) {
  final reverse = reverseRateFor(rate);
  if (reverse == null) return null;
  return '1 ${pair.quote} = ${formatFavoriteRate(reverse)} ${pair.base}';
}
