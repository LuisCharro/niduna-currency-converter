class CurrencyQuote {
  const CurrencyQuote(
    this.symbol,
    this.code,
    this.name,
    this.amount,
    this.rateLine, {
    required this.rate,
    this.favorite = false,
  });

  final String symbol;
  final String code;
  final String name;
  final String amount;
  final String rateLine;
  final double rate;
  final bool favorite;
}
