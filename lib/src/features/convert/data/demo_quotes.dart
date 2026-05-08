import '../models/currency_quote.dart';

const List<CurrencyQuote> demoQuotes = <CurrencyQuote>[
  CurrencyQuote('€', 'EUR', 'Euro', '92.45', '1 USD = 0.9245 EUR'),
  CurrencyQuote('Fr', 'CHF', 'Swiss Franc', '88.30', '1 USD = 0.8830 CHF'),
  CurrencyQuote(
    '£',
    'GBP',
    'British Pound',
    '79.15',
    '1 USD = 0.7915 GBP',
    favorite: true,
  ),
  CurrencyQuote('¥', 'JPY', 'Japanese Yen', '15,023.00', '1 USD = 150.23 JPY'),
  CurrencyQuote(
    r'CA$',
    'CAD',
    'Canadian Dollar',
    '135.40',
    '1 USD = 1.3540 CAD',
  ),
  CurrencyQuote(
    r'AU$',
    'AUD',
    'Australian Dollar',
    '152.10',
    '1 USD = 1.5210 AUD',
  ),
  CurrencyQuote('¥', 'CNY', 'Chinese Yuan', '718.20', '1 USD = 7.1820 CNY'),
  CurrencyQuote('₹', 'INR', 'Indian Rupee', '8,325.00', '1 USD = 83.2500 INR'),
  CurrencyQuote(r'MX$', 'MXN', 'Mexican Peso', '1,725.00', '1 USD = 17.2500 MXN'),
  CurrencyQuote(r'R$', 'BRL', 'Brazilian Real', '506.00', '1 USD = 5.0600 BRL'),
  CurrencyQuote('₺', 'TRY', 'Turkish Lira', '3,220.00', '1 USD = 32.2000 TRY'),
  CurrencyQuote('₩', 'KRW', 'South Korean Won', '136,800', '1 USD = 1368.00 KRW'),
  CurrencyQuote(r'S$', 'SGD', 'Singapore Dollar', '134.80', '1 USD = 1.3480 SGD'),
  CurrencyQuote(r'HK$', 'HKD', 'Hong Kong Dollar', '783.10', '1 USD = 7.8310 HKD'),
  CurrencyQuote(r'NZ$', 'NZD', 'New Zealand Dollar', '164.30', '1 USD = 1.6430 NZD'),
];
