/// Currencies whose ISO 4217 minor unit is 0 (no fractional subunit in
/// everyday use) among the app's supported fiat currencies.
///
/// Kept deliberately small and explicit: only currencies actually present in
/// `supportedFiatCurrencies` need an entry. HUF is officially minor unit 2
/// and is intentionally excluded.
const Set<String> zeroDecimalCurrencyCodes = <String>{'JPY', 'KRW', 'CLP'};

/// Whether [code] is a zero-decimal currency (no minor unit shown).
bool isZeroDecimalCurrency(String code) =>
    zeroDecimalCurrencyCodes.contains(code);

/// Resolves how many decimal places a converted amount in [code] should be
/// displayed with. Zero-decimal currencies always render with 0 decimals
/// regardless of the user's configured [defaultDecimalPlaces]; every other
/// currency uses [defaultDecimalPlaces] unchanged.
///
/// This only applies to *converted amounts* (e.g. "¥15,733"), never to
/// "1 USD = 157.33 JPY" style rate lines, which keep their own precision.
int decimalsForCurrency(String code, int defaultDecimalPlaces) {
  if (isZeroDecimalCurrency(code)) return 0;
  return defaultDecimalPlaces;
}
