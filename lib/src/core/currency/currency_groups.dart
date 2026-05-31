import 'supported_currencies.dart';

enum CurrencySection {
  major,
  europe,
  americas,
  asiaPacific,
  middleEastAfrica,
  crypto;

  String get label {
    switch (this) {
      case CurrencySection.major:
        return 'Major';
      case CurrencySection.europe:
        return 'Europe';
      case CurrencySection.americas:
        return 'Americas';
      case CurrencySection.asiaPacific:
        return 'Asia Pacific';
      case CurrencySection.middleEastAfrica:
        return 'Middle East & Africa';
      case CurrencySection.crypto:
        return 'Crypto';
    }
  }

  bool get defaultExpanded =>
      this == CurrencySection.major || this == CurrencySection.crypto;
}

class CurrencyGroup {
  const CurrencyGroup({
    required this.section,
    required this.currencies,
  });

  final CurrencySection section;
  final List<SupportedCurrency> currencies;

  int get length => currencies.length;
}

List<CurrencyGroup> buildCurrencyGroups({
  required List<SupportedCurrency> currencies,
}) {
  const majorCodes = <String>{
    'USD', 'EUR', 'GBP', 'JPY', 'CNY',
  };
  const europeCodes = <String>{
    'CHF', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF', 'RON',
  };
  const americasCodes = <String>{
    'CAD', 'AUD', 'MXN', 'BRL', 'ARS', 'CLP', 'COP',
  };
  const asiaPacificCodes = <String>{
    'INR', 'SGD', 'HKD', 'KRW', 'THB', 'PHP', 'IDR', 'MYR', 'TWD', 'NZD',
  };
  const meAfricaCodes = <String>{
    'TRY', 'AED', 'ILS', 'ZAR',
  };

  final groups = <CurrencyGroup>[];

  final major = currencies.where((c) => majorCodes.contains(c.code)).toList();
  if (major.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.major, currencies: major));
  }

  final europe = currencies.where((c) => europeCodes.contains(c.code)).toList();
  if (europe.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.europe, currencies: europe));
  }

  final americas = currencies.where((c) => americasCodes.contains(c.code)).toList();
  if (americas.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.americas, currencies: americas));
  }

  final asiaPacific = currencies.where((c) => asiaPacificCodes.contains(c.code)).toList();
  if (asiaPacific.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.asiaPacific, currencies: asiaPacific));
  }

  final meAfrica = currencies.where((c) => meAfricaCodes.contains(c.code)).toList();
  if (meAfrica.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.middleEastAfrica, currencies: meAfrica));
  }

  final crypto = currencies.where((c) => isCryptoCurrency(c.code)).toList();
  if (crypto.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.crypto, currencies: crypto));
  }

  return groups;
}
