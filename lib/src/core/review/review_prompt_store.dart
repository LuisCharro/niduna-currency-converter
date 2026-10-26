import 'package:shared_preferences/shared_preferences.dart';

import 'review_prompt_policy.dart';

/// Persists [ReviewPromptStats] in SharedPreferences. An "active day" is a
/// local calendar day on which the app was opened or a conversion was made.
class ReviewPromptStore {
  ReviewPromptStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _firstSeenKey = 'review_prompt_first_seen';
  static const String _activeDaysKey = 'review_prompt_active_days';
  static const String _lastActiveDayKey = 'review_prompt_last_active_day';
  static const String _requestCountKey = 'review_prompt_request_count';
  static const String _lastRequestKey = 'review_prompt_last_request';

  ReviewPromptStats read() => ReviewPromptStats(
    firstSeen: _readDate(_firstSeenKey),
    activeDays: _prefs.getInt(_activeDaysKey) ?? 0,
    requestCount: _prefs.getInt(_requestCountKey) ?? 0,
    lastRequestAt: _readDate(_lastRequestKey),
  );

  Future<void> recordActiveDay(DateTime now) async {
    if (_prefs.getString(_firstSeenKey) == null) {
      await _prefs.setString(_firstSeenKey, now.toIso8601String());
    }
    final day = _dayKey(now);
    if (_prefs.getString(_lastActiveDayKey) == day) return;
    await _prefs.setString(_lastActiveDayKey, day);
    await _prefs.setInt(
      _activeDaysKey,
      (_prefs.getInt(_activeDaysKey) ?? 0) + 1,
    );
  }

  Future<void> recordRequest(DateTime now) async {
    await _prefs.setInt(
      _requestCountKey,
      (_prefs.getInt(_requestCountKey) ?? 0) + 1,
    );
    await _prefs.setString(_lastRequestKey, now.toIso8601String());
  }

  DateTime? _readDate(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  static String _dayKey(DateTime now) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}
