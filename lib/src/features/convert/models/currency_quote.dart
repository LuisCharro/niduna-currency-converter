import 'trend_direction.dart';

class CurrencyQuote {
  const CurrencyQuote(
    this.symbol,
    this.code,
    this.name,
    this.amount,
    this.rateLine, {
    required this.rate,
    this.favorite = false,
    this.previousRate,
  });

  final String symbol;
  final String code;
  final String name;
  final String amount;
  final String rateLine;
  final double rate;
  final bool favorite;
  final double? previousRate;

  TrendDirection? get trend {
    if (previousRate == null) return null;
    if (rate > previousRate!) return TrendDirection.up;
    if (rate < previousRate!) return TrendDirection.down;
    return TrendDirection.flat;
  }

  double? get changePercent {
    if (previousRate == null || previousRate == 0) return null;
    return ((rate - previousRate!) / previousRate!) * 100;
  }
}
