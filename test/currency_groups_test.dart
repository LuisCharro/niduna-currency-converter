import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/currency/currency_groups.dart';
import 'package:currency_converter/src/core/currency/supported_currencies.dart';

void main() {
  test('all 34 fiat currencies assigned to exactly one region', () {
    const europeCodes = <String>{
      'EUR', 'GBP', 'CHF', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF', 'RON',
    };
    const americasCodes = <String>{
      'USD', 'CAD', 'AUD', 'MXN', 'BRL', 'ARS', 'CLP', 'COP',
    };
    const asiaPacificCodes = <String>{
      'JPY', 'CNY', 'INR', 'SGD', 'HKD', 'KRW', 'THB', 'PHP', 'IDR', 'MYR',
      'TWD', 'NZD',
    };
    const meAfricaCodes = <String>{
      'TRY', 'AED', 'ILS', 'ZAR',
    };

    final allRegionCodes = <String>{
      ...europeCodes,
      ...americasCodes,
      ...asiaPacificCodes,
      ...meAfricaCodes,
    };

    final fiatCodes = supportedFiatCurrencies.map((c) => c.code).toSet();
    expect(fiatCodes, allRegionCodes);
    expect(fiatCodes.length, 34);
  });

  test('Europe has exactly 10 codes', () {
    const europeCodes = <String>{
      'EUR', 'GBP', 'CHF', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF', 'RON',
    };
    expect(europeCodes.length, 10);

    final groups = buildCurrencyGroups(currencies: supportedFiatCurrencies);
    final europe = groups.firstWhere(
      (g) => g.section == CurrencySection.europe,
    );
    expect(europe.length, 10);
  });

  test('Americas has exactly 8 codes', () {
    const americasCodes = <String>{
      'USD', 'CAD', 'AUD', 'MXN', 'BRL', 'ARS', 'CLP', 'COP',
    };
    expect(americasCodes.length, 8);

    final groups = buildCurrencyGroups(currencies: supportedFiatCurrencies);
    final americas = groups.firstWhere(
      (g) => g.section == CurrencySection.americas,
    );
    expect(americas.length, 8);
  });

  test('AsiaPacific has exactly 12 codes', () {
    const asiaPacificCodes = <String>{
      'JPY', 'CNY', 'INR', 'SGD', 'HKD', 'KRW', 'THB', 'PHP', 'IDR', 'MYR',
      'TWD', 'NZD',
    };
    expect(asiaPacificCodes.length, 12);

    final groups = buildCurrencyGroups(currencies: supportedFiatCurrencies);
    final asiaPacific = groups.firstWhere(
      (g) => g.section == CurrencySection.asiaPacific,
    );
    expect(asiaPacific.length, 12);
  });

  test('MiddleEastAfrica has exactly 4 codes', () {
    const meAfricaCodes = <String>{
      'TRY', 'AED', 'ILS', 'ZAR',
    };
    expect(meAfricaCodes.length, 4);

    final groups = buildCurrencyGroups(currencies: supportedFiatCurrencies);
    final meAfrica = groups.firstWhere(
      (g) => g.section == CurrencySection.middleEastAfrica,
    );
    expect(meAfrica.length, 4);
  });

  test('Crypto section has exactly 11 codes', () {
    final groups = buildCurrencyGroups(
      currencies: allSupportedCurrencies,
    );
    final crypto = groups.firstWhere(
      (g) => g.section == CurrencySection.crypto,
    );
    expect(crypto.length, 11);
  });

  test('empty input returns empty groups', () {
    final groups = buildCurrencyGroups(currencies: []);
    expect(groups, isEmpty);
  });

  test('only crypto input returns single Crypto group', () {
    final groups = buildCurrencyGroups(currencies: supportedCryptoCurrencies);
    expect(groups.length, 1);
    expect(groups.single.section, CurrencySection.crypto);
  });

  test('default expanded is Crypto only', () {
    expect(CurrencySection.crypto.defaultExpanded, isTrue);
    expect(CurrencySection.europe.defaultExpanded, isFalse);
    expect(CurrencySection.americas.defaultExpanded, isFalse);
    expect(CurrencySection.asiaPacific.defaultExpanded, isFalse);
    expect(CurrencySection.middleEastAfrica.defaultExpanded, isFalse);
  });
}
