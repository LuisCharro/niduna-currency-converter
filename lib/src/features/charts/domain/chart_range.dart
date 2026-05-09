enum ChartRange {
  oneWeek('1W', 7),
  oneMonth('1M', 30),
  threeMonths('3M', 90),
  sixMonths('6M', 180),
  oneYear('1Y', 365),
  twoYears('2Y', 730);

  const ChartRange(this.label, this.days);

  final String label;
  final int days;

  DateTime fromDate() {
    return DateTime.now().subtract(Duration(days: days));
  }

  String get cacheKey => '${days}d';
}