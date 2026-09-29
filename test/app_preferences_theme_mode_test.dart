import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/core/preferences/app_preferences.dart';

void main() {
  group('AppPreferences.themeMode', () {
    test('defaults to system when no key is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      expect(preferences.themeMode, AppThemeMode.system);
    });

    test('migrates legacy pref_dark_mode=true to dark', () async {
      SharedPreferences.setMockInitialValues({'pref_dark_mode': true});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      expect(preferences.themeMode, AppThemeMode.dark);
    });

    test('migrates legacy pref_dark_mode=false to light', () async {
      SharedPreferences.setMockInitialValues({'pref_dark_mode': false});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      expect(preferences.themeMode, AppThemeMode.light);
    });

    test('new pref_theme_mode key takes precedence over legacy key', () async {
      SharedPreferences.setMockInitialValues({
        'pref_dark_mode': true,
        'pref_theme_mode': 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      expect(preferences.themeMode, AppThemeMode.light);
    });

    test('setThemeMode persists and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      var notified = false;
      preferences.addListener(() => notified = true);

      await preferences.setThemeMode(AppThemeMode.dark);

      expect(preferences.themeMode, AppThemeMode.dark);
      expect(prefs.getString('pref_theme_mode'), 'dark');
      expect(notified, isTrue);

      await preferences.setThemeMode(AppThemeMode.system);
      expect(preferences.themeMode, AppThemeMode.system);
      expect(prefs.getString('pref_theme_mode'), 'system');
    });

    test('an unrecognized stored value falls back to system', () async {
      SharedPreferences.setMockInitialValues({'pref_theme_mode': 'nonsense'});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      expect(preferences.themeMode, AppThemeMode.system);
    });
  });
}
