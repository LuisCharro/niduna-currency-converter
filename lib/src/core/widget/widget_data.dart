class WidgetPair {
  const WidgetPair({
    required this.code,
    required this.symbol,
    required this.value,
    this.trend = 'none',
    this.changePercent = '',
  });

  final String code;
  final String symbol;
  final String value;
  final String trend;
  final String changePercent;
}

class HomeWidgetData {
  const HomeWidgetData({
    this.baseCode = 'USD',
    this.amountLabel = '100 USD',
    this.updatedLabel = '',
    this.pairs = const <WidgetPair>[],
  });

  final String baseCode;
  final String amountLabel;
  final String updatedLabel;
  final List<WidgetPair> pairs;
}
