class CurrencyQuote {
  const CurrencyQuote(
    this.symbol,
    this.code,
    this.name,
    this.amount,
    this.rateLine, {
    this.favorite = false,
  });

  final String symbol;
  final String code;
  final String name;
  final String amount;
  final String rateLine;
  final bool favorite;
}
