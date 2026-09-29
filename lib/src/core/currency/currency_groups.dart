import 'supported_currencies.dart';

enum CurrencySection {
  europe,
  americas,
  asiaPacific,
  middleEastAfrica,
  crypto;

  String get label {
    switch (this) {
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

  bool get defaultExpanded => false;
}

/// Widely-used currencies offered as quick picks in picker sheets, ahead of
/// the collapsible region groups. Only codes present in a given picker's
/// currency list are ever shown.
const List<String> popularCurrencyCodes = <String>[
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'CHF',
  'CAD',
  'AUD',
  'CNY',
  'BTC',
  'ETH',
];

/// The region/category section that contains [code], if any, computed from
/// [currencies]. Used to auto-expand the group holding the current
/// base/quote when a picker opens.
CurrencySection? sectionForCode(String code, List<SupportedCurrency> currencies) {
  for (final group in buildCurrencyGroups(currencies: currencies)) {
    if (group.currencies.any((c) => c.code == code)) return group.section;
  }
  return null;
}

class CurrencyGroup {
  const CurrencyGroup({required this.section, required this.currencies});

  final CurrencySection section;
  final List<SupportedCurrency> currencies;

  int get length => currencies.length;
}

List<CurrencyGroup> buildCurrencyGroups({
  required List<SupportedCurrency> currencies,
}) {
  const europeCodes = <String>{
    'EUR',
    'GBP',
    'CHF',
    'SEK',
    'NOK',
    'DKK',
    'PLN',
    'CZK',
    'HUF',
    'RON',
  };
  const americasCodes = <String>{
    'USD',
    'CAD',
    'AUD',
    'MXN',
    'BRL',
    'ARS',
    'CLP',
    'COP',
  };
  const asiaPacificCodes = <String>{
    'JPY',
    'CNY',
    'INR',
    'SGD',
    'HKD',
    'KRW',
    'THB',
    'PHP',
    'IDR',
    'MYR',
    'TWD',
    'NZD',
  };
  const meAfricaCodes = <String>{'TRY', 'AED', 'ILS', 'ZAR'};

  final groups = <CurrencyGroup>[];

  final europe = currencies.where((c) => europeCodes.contains(c.code)).toList();
  if (europe.isNotEmpty) {
    groups.add(
      CurrencyGroup(section: CurrencySection.europe, currencies: europe),
    );
  }

  final americas = currencies
      .where((c) => americasCodes.contains(c.code))
      .toList();
  if (americas.isNotEmpty) {
    groups.add(
      CurrencyGroup(section: CurrencySection.americas, currencies: americas),
    );
  }

  final asiaPacific = currencies
      .where((c) => asiaPacificCodes.contains(c.code))
      .toList();
  if (asiaPacific.isNotEmpty) {
    groups.add(
      CurrencyGroup(
        section: CurrencySection.asiaPacific,
        currencies: asiaPacific,
      ),
    );
  }

  final meAfrica = currencies
      .where((c) => meAfricaCodes.contains(c.code))
      .toList();
  if (meAfrica.isNotEmpty) {
    groups.add(
      CurrencyGroup(
        section: CurrencySection.middleEastAfrica,
        currencies: meAfrica,
      ),
    );
  }

  final crypto = currencies.where((c) => isCryptoCurrency(c.code)).toList();
  if (crypto.isNotEmpty) {
    groups.add(
      CurrencyGroup(section: CurrencySection.crypto, currencies: crypto),
    );
  }

  return groups;
}
