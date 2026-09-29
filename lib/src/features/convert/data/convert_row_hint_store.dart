import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has dismissed (or already earned, by
/// successfully opening the Conversion Lens once) the one-time
/// discoverability hint for row actions on the Convert rates list.
class ConvertRowHintStore {
  ConvertRowHintStore(this._preferences);

  static const _key = 'hint_convert_row_actions_seen';

  final SharedPreferences _preferences;

  bool get seen => _preferences.getBool(_key) ?? false;

  Future<void> markSeen() => _preferences.setBool(_key, true);
}
