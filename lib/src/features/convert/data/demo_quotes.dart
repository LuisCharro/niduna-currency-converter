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
  CurrencyQuote('₿', 'BTC', 'Bitcoin', '0.0014', '1 USD = 0.000014 BTC'),
  CurrencyQuote('Ξ', 'ETH', 'Ethereum', '0.026', '1 USD = 0.00026 ETH'),
];
