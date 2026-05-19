import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _defaultBaseKey = 'pref_default_base';
  static const String _decimalPlacesKey = 'pref_decimal_places';
  static const String _refreshOnOpenKey = 'pref_refresh_on_open';
  static const String _devModeKey = 'pref_dev_mode';
  static const String _darkModeKey = 'pref_dark_mode';
  static const String _selectedCodesKey = 'pref_selected_codes';
  static const bool _defaultDevMode = bool.fromEnvironment(
    'APP_DEV_MODE',
    defaultValue: false,
  );

  static const List<String> defaultSelectedCodes = ['EUR', 'GBP', 'JPY'];

  String get defaultBaseCurrency => _prefs.getString(_defaultBaseKey) ?? 'USD';
  int get decimalPlaces => _prefs.getInt(_decimalPlacesKey) ?? 2;
  bool get refreshOnOpen => _prefs.getBool(_refreshOnOpenKey) ?? true;
  bool get devMode => _prefs.getBool(_devModeKey) ?? _defaultDevMode;
  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;

  bool get isDecimalPlacesSupported => decimalPlaces >= 2 && decimalPlaces <= 6;

  List<String> get selectedCodes {
    final codes = _prefs.getStringList(_selectedCodesKey);
    if (codes == null || codes.isEmpty) return defaultSelectedCodes;
    return codes;
  }

  Future<void> setSelectedCodes(List<String> codes) async {
    await _prefs.setStringList(_selectedCodesKey, codes);
    notifyListeners();
  }

  Future<void> setDefaultBaseCurrency(String code) async {
    await _prefs.setString(_defaultBaseKey, code);
    notifyListeners();
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
    await _prefs.setBool(_devModeKey, value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
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
}
