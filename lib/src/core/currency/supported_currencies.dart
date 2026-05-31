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

const List<SupportedCurrency> supportedFiatCurrencies = <SupportedCurrency>[
  // ── Major ──────────────────────────────────────
  SupportedCurrency(code: 'USD', name: 'US Dollar', symbol: r'$'),
  SupportedCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
  SupportedCurrency(code: 'GBP', name: 'British Pound', symbol: '£'),
  SupportedCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  SupportedCurrency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  // ── Europe ─────────────────────────────────────
  SupportedCurrency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
  SupportedCurrency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
  SupportedCurrency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
  SupportedCurrency(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
  SupportedCurrency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł'),
  SupportedCurrency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč'),
  SupportedCurrency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft'),
  SupportedCurrency(code: 'RON', name: 'Romanian Leu', symbol: 'lei'),
  // ── Americas ───────────────────────────────────
  SupportedCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: r'CA$'),
  SupportedCurrency(code: 'AUD', name: 'Australian Dollar', symbol: r'AU$'),
  SupportedCurrency(code: 'MXN', name: 'Mexican Peso', symbol: r'MX$'),
  SupportedCurrency(code: 'BRL', name: 'Brazilian Real', symbol: r'R$'),
  SupportedCurrency(code: 'ARS', name: 'Argentine Peso', symbol: r'AR$'),
  SupportedCurrency(code: 'CLP', name: 'Chilean Peso', symbol: r'CLP$'),
  SupportedCurrency(code: 'COP', name: 'Colombian Peso', symbol: r'COP$'),
  // ── Asia Pacific ───────────────────────────────
  SupportedCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  SupportedCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$'),
  SupportedCurrency(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$'),
  SupportedCurrency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  SupportedCurrency(code: 'THB', name: 'Thai Baht', symbol: '฿'),
  SupportedCurrency(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
  SupportedCurrency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
  SupportedCurrency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
  SupportedCurrency(code: 'TWD', name: 'Taiwan Dollar', symbol: r'NT$'),
  SupportedCurrency(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$'),
  // ── Middle East & Africa ──────────────────────
  SupportedCurrency(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
  SupportedCurrency(code: 'AED', name: 'UAE Dirham', symbol: r'AED'),
  SupportedCurrency(code: 'ILS', name: 'Israeli Shekel', symbol: '₪'),
  SupportedCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
];

const List<SupportedCurrency> supportedCryptoCurrencies = <SupportedCurrency>[
  SupportedCurrency(code: 'BTC', name: 'Bitcoin', symbol: 'BTC'),
  SupportedCurrency(code: 'ETH', name: 'Ethereum', symbol: 'ETH'),
  SupportedCurrency(code: 'SOL', name: 'Solana', symbol: 'SOL'),
  SupportedCurrency(code: 'XRP', name: 'Ripple', symbol: 'XRP'),
  SupportedCurrency(code: 'ADA', name: 'Cardano', symbol: 'ADA'),
  SupportedCurrency(code: 'DOGE', name: 'Dogecoin', symbol: 'DOGE'),
  SupportedCurrency(code: 'AVAX', name: 'Avalanche', symbol: 'AVAX'),
  SupportedCurrency(code: 'USDT', name: 'Tether USD', symbol: '₮'),
  SupportedCurrency(code: 'USDC', name: 'USD Coin', symbol: 'USDC'),
  SupportedCurrency(code: 'BNB', name: 'BNB', symbol: 'BNB'),
  SupportedCurrency(code: 'MATIC', name: 'Polygon', symbol: 'MATIC'),
];

const List<SupportedCurrency> supportedCurrencies = supportedFiatCurrencies;

List<SupportedCurrency> get allSupportedCurrencies => <SupportedCurrency>[
  ...supportedFiatCurrencies,
  ...supportedCryptoCurrencies,
];

bool isFiatCurrency(String code) {
  return supportedFiatCurrencies.any((currency) => currency.code == code);
}

bool isCryptoCurrency(String code) {
  return supportedCryptoCurrencies.any((currency) => currency.code == code);
}

SupportedCurrency currencyByCode(String code) {
  return allSupportedCurrencies.firstWhere(
    (currency) => currency.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unsupported currency'),
  );
}
