import 'trend_direction.dart';

/// Day-over-day trend helpers shared by the Convert rows and the Favorites
/// rows so the direction, percentage, and "is it worth showing" rule live in
/// one place.

TrendDirection? trendDirectionFor(double? rate, double? previousRate) {
  if (rate == null || previousRate == null) return null;
  if (rate > previousRate) return TrendDirection.up;
  if (rate < previousRate) return TrendDirection.down;
  return TrendDirection.flat;
}

double? changePercentFor(double? rate, double? previousRate) {
  if (rate == null || previousRate == null || previousRate == 0) return null;
  return ((rate - previousRate) / previousRate) * 100;
}

/// A badge is shown only for a meaningful move: not flat, and not a change
/// that rounds to 0.00% (e.g. when the prior business day's rate is unchanged).
bool shouldShowTrend(TrendDirection? trend, double? changePercent) =>
    trend != null &&
    trend != TrendDirection.flat &&
    (changePercent == null || changePercent.abs() >= 0.005);
