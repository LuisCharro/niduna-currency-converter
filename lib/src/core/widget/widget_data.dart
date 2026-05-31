class HomeWidgetData {
  const HomeWidgetData({
    this.baseCode = 'USD',
    this.quoteCode = 'EUR',
    this.rate = 0.0,
    this.amount = 100.0,
    this.convertedAmount = '',
    this.updatedAt = '',
  });

  final String baseCode;
  final String quoteCode;
  final double rate;
  final double amount;
  final String convertedAmount;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'baseCode': baseCode,
        'quoteCode': quoteCode,
        'rate': rate,
        'amount': amount,
        'convertedAmount': convertedAmount,
        'updatedAt': updatedAt,
      };

  factory HomeWidgetData.fromJson(Map<String, dynamic> json) => HomeWidgetData(
        baseCode: json['baseCode'] as String? ?? 'USD',
        quoteCode: json['quoteCode'] as String? ?? 'EUR',
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        amount: (json['amount'] as num?)?.toDouble() ?? 100.0,
        convertedAmount: json['convertedAmount'] as String? ?? '',
        updatedAt: json['updatedAt'] as String? ?? '',
      );
}
