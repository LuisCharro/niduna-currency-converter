import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _defaultBaseKey = 'pref_default_base';
  static const String _decimalPlacesKey = 'pref_decimal_places';
  static const String _refreshOnOpenKey = 'pref_refresh_on_open';
  static const String _devModeKey = 'pref_dev_mode';

  String get defaultBaseCurrency => _prefs.getString(_defaultBaseKey) ?? 'USD';
  int get decimalPlaces => _prefs.getInt(_decimalPlacesKey) ?? 2;
  bool get refreshOnOpen => _prefs.getBool(_refreshOnOpenKey) ?? true;
  bool get devMode => _prefs.getBool(_devModeKey) ?? true;

  bool get isDecimalPlacesSupported => decimalPlaces >= 2 && decimalPlaces <= 6;

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

  Future<void> clearAllCaches() async {
    final keysToRemove = _prefs.getKeys().where((k) =>
        k.startsWith('rates_') ||
        k.startsWith('historical_') ||
        k.startsWith('temp_unlock'));
    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
    notifyListeners();
  }

  static const List<int> supportedDecimalPlaces = [2, 3, 4, 5, 6];
}