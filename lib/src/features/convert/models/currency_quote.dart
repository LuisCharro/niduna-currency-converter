import 'trend.dart';
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

  TrendDirection? get trend => trendDirectionFor(rate, previousRate);

  double? get changePercent => changePercentFor(rate, previousRate);
}
