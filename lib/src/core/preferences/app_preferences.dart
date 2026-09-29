import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../currency/currency_code_migration.dart';
import '../currency/supported_currencies.dart';

/// Theme preference. `system` follows the OS setting; `light`/`dark` are
/// explicit overrides.
enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromName(String? name) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => AppThemeMode.system,
    );
  }
}

class AppPreferences extends ChangeNotifier {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _defaultBaseKey = 'pref_default_base';
  static const String _decimalPlacesKey = 'pref_decimal_places';
  static const String _refreshOnOpenKey = 'pref_refresh_on_open';
  static const String _devModeKey = 'pref_dev_mode';
  static const String _darkModeKey = 'pref_dark_mode';
  static const String _themeModeKey = 'pref_theme_mode';
  static const String _selectedCodesKey = 'pref_selected_codes';
  static const bool _defaultDevMode = bool.fromEnvironment(
    'APP_DEV_MODE',
    defaultValue: false,
  );

  static const List<String> defaultSelectedCodes = ['EUR', 'GBP', 'JPY', 'BTC'];

  String get defaultBaseCurrency {
    final code = canonicalCurrencyCode(
      _prefs.getString(_defaultBaseKey) ?? 'USD',
    );
    return isFiatCurrency(code) ? code : 'USD';
  }

  int get decimalPlaces => _prefs.getInt(_decimalPlacesKey) ?? 2;
  bool get refreshOnOpen => _prefs.getBool(_refreshOnOpenKey) ?? true;
  bool get devToolsAvailable => kDebugMode;
  bool get devMode =>
      devToolsAvailable && (_prefs.getBool(_devModeKey) ?? _defaultDevMode);
  /// Effective theme preference. Reads the new tri-state key when present;
  /// otherwise migrates from the legacy `pref_dark_mode` boolean:
  /// absent -> [AppThemeMode.system], `true` -> [AppThemeMode.dark],
  /// `false` -> [AppThemeMode.light].
  AppThemeMode get themeMode {
    final stored = _prefs.getString(_themeModeKey);
    if (stored != null) return AppThemeMode.fromName(stored);

    final legacyDark = _prefs.getBool(_darkModeKey);
    if (legacyDark == true) return AppThemeMode.dark;
    if (legacyDark == false) return AppThemeMode.light;
    return AppThemeMode.system;
  }

  bool get isDecimalPlacesSupported => decimalPlaces >= 2 && decimalPlaces <= 6;

  List<String> get selectedCodes {
    final codes = _prefs.getStringList(_selectedCodesKey);
    if (codes == null || codes.isEmpty) return defaultSelectedCodes;
    final supported = _supportedCodes(codes);
    return supported.isEmpty ? defaultSelectedCodes : supported;
  }

  Future<void> setSelectedCodes(List<String> codes) async {
    await _prefs.setStringList(_selectedCodesKey, _supportedCodes(codes));
    notifyListeners();
  }

  Future<void> setDefaultBaseCurrency(String code) async {
    final canonical = canonicalCurrencyCode(code);
    if (!isFiatCurrency(canonical)) return;
    await _prefs.setString(_defaultBaseKey, canonical);
    notifyListeners();
  }

  Future<void> migrateCurrencyCodesIfNeeded() async {
    var changed = false;
    final storedBase = _prefs.getString(_defaultBaseKey);
    if (storedBase != null && storedBase != defaultBaseCurrency) {
      await _prefs.setString(_defaultBaseKey, defaultBaseCurrency);
      changed = true;
    }

    final storedCodes = _prefs.getStringList(_selectedCodesKey);
    if (storedCodes != null) {
      final migrated = _supportedCodes(storedCodes);
      final normalized = migrated.isEmpty ? defaultSelectedCodes : migrated;
      if (!_listEquals(storedCodes, normalized)) {
        await _prefs.setStringList(_selectedCodesKey, normalized);
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  Future<void> setDecimalPlaces(int value) async {
    if (value < 2 || value > 6) return;
    await _prefs.setInt(_decimalPlacesKey, value);
    notifyListeners();
  }

  Future<void> setRefreshOnOpen(bool value) async {
    await _prefs.setBool(_refreshOnOpenKey, value);
    notifyListeners();
  }

  Future<void> setDevMode(bool value) async {
    if (!devToolsAvailable) return;
    await _prefs.setBool(_devModeKey, value);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> clearAllCaches() async {
    final keysToRemove = _prefs.getKeys().where(
      (k) =>
          k.startsWith('latest_rates_') ||
          k.startsWith('rates_') ||
          k.startsWith('historical_') ||
          k.startsWith('crypto_usd_prices_') ||
          k.startsWith('crypto_usd_history_') ||
          k.startsWith('temp_unlock'),
    );
    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
    notifyListeners();
  }

  static const List<int> supportedDecimalPlaces = [2, 3, 4, 5, 6];

  static List<String> _supportedCodes(List<String> codes) =>
      canonicalizeCodeList(codes).where(isSupportedCurrencyCode).toList();

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
