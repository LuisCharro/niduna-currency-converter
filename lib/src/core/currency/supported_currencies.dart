class SupportedCurrency {
  const SupportedCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;
}

const List<SupportedCurrency> supportedCurrencies = <SupportedCurrency>[
  SupportedCurrency(code: 'USD', name: 'US Dollar', symbol: r'$'),
  SupportedCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
  SupportedCurrency(code: 'GBP', name: 'British Pound', symbol: '£'),
  SupportedCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  SupportedCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: r'CA$'),
  SupportedCurrency(code: 'AUD', name: 'Australian Dollar', symbol: r'AU$'),
  SupportedCurrency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  SupportedCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  SupportedCurrency(code: 'MXN', name: 'Mexican Peso', symbol: r'MX$'),
  SupportedCurrency(code: 'BRL', name: 'Brazilian Real', symbol: r'R$'),
  SupportedCurrency(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
  SupportedCurrency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  SupportedCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$'),
  SupportedCurrency(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$'),
  SupportedCurrency(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$'),
  SupportedCurrency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
];

SupportedCurrency currencyByCode(String code) {
  return supportedCurrencies.firstWhere(
    (currency) => currency.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unsupported fiat'),
  );
}
