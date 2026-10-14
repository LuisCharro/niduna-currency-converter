part of 'app_preferences.dart';

extension ConvertSelectionPreferences on AppPreferences {
  static const _baseKey = 'pref_convert_base';
  static const _collectionKey = 'pref_currency_collection';

  String get convertBaseCurrency {
    final code = canonicalCurrencyCode(
      _prefs.getString(_baseKey) ?? defaultBaseCurrency,
    );
    return isSupportedCurrencyCode(code) ? code : defaultBaseCurrency;
  }

  List<String> get savedCurrencyCodes {
    final stored = _prefs.getStringList(_collectionKey);
    final codes = AppPreferences._supportedCodes(
      stored ?? [convertBaseCurrency, ...selectedCodes],
    );
    if (!codes.contains(convertBaseCurrency)) {
      codes.insert(0, convertBaseCurrency);
    }
    if (codes.length == 1) {
      codes.addAll(
        AppPreferences.defaultSelectedCodes.where(
          (code) => code != convertBaseCurrency,
        ),
      );
    }
    return codes;
  }

  Future<void> saveConvertSelection(
    String base,
    List<String> collection,
  ) async {
    final canonical = canonicalCurrencyCode(base);
    if (!isSupportedCurrencyCode(canonical)) return;
    final codes = AppPreferences._supportedCodes(collection);
    if (!codes.contains(canonical)) codes.insert(0, canonical);
    // Keep the old quote-only key for migration and existing consumers.
    await _prefs.setStringList(_collectionKey, codes);
    await _prefs.setStringList(
      AppPreferences._selectedCodesKey,
      codes.where((code) => code != canonical).toList(),
    );
    await _prefs.setString(_baseKey, canonical);
  }
}
