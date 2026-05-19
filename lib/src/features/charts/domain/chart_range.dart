enum ChartRange {
  oneHour('1H', 0, locked: true),
  sixHours('6H', 0, locked: true),
  oneDay('1D', 0, locked: true),
  oneWeek('1W', 7),
  oneMonth('1M', 30),
  threeMonths('3M', 90),
  sixMonths('6M', 180),
  oneYear('1Y', 365),
  twoYears('2Y', 730);

  const ChartRange(this.label, this.days, {this.locked = false});

  final String label;
  final int days;
  final bool locked;

  bool get supportsCrypto => days > 0 && days <= 365;

  DateTime? fromDate() {
    if (days <= 0) return null;
    return DateTime.now().subtract(Duration(days: days));
  }

  String get cacheKey => '${days}d';
}
