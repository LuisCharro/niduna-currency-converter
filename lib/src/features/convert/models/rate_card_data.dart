/// Plain data for the shareable rate card — independent of ConvertState so the
/// card widget can be rendered and tested in isolation.
class RateCardData {
  const RateCardData({
    required this.baseAmountLabel,
    required this.rows,
    required this.footerLabel,
  });

  final String baseAmountLabel; // e.g. "100 USD"
  final List<RateCardRowData> rows;
  final String footerLabel; // e.g. "Updated Jun 15"
}

class RateCardRowData {
  const RateCardRowData({required this.name, required this.valueLabel});

  final String name; // e.g. "Euro"
  final String valueLabel; // e.g. "€ 86.34"
}
