import '../../currency/supported_currencies.dart';

class RateNormalizer {
  const RateNormalizer();

  Map<String, double> normalizeFiatBase({
    required String base,
    required Map<String, double> fiatRates,
    required Map<String, double> cryptoUsdPrices,
  }) {
    if (isCryptoCurrency(base)) {
      throw ArgumentError.value(base, 'base', 'Crypto base not supported yet');
    }

    final rates = Map<String, double>.from(fiatRates);
    final baseToUsd = base == 'USD' ? 1.0 : fiatRates['USD'];
    if (baseToUsd == null || baseToUsd <= 0) {
      throw ArgumentError('Missing USD rate for fiat base normalization');
    }

    for (final entry in cryptoUsdPrices.entries) {
      rates[entry.key] = baseToUsd / entry.value;
    }

    return rates;
  }
}
