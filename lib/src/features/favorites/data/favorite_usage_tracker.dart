import 'package:shared_preferences/shared_preferences.dart';

import '../domain/favorite_pair.dart';

mixin FavoriteUsageTracker {
  SharedPreferences get prefs;

  static const _usageKey = 'favorite_usage';
  static const _timestampKey = 'favorite_timestamps';

  int usageCount(String base, String quote) {
    final key = FavoritePair(base: base, quote: quote).toKey();
    final counts = prefs.getStringList(_usageKey);
    if (counts == null) return 0;
    return counts.where((k) => k == key).length;
  }

  Future<void> recordUsage(String base, String quote) async {
    final key = FavoritePair(base: base, quote: quote).toKey();
    final counts = prefs.getStringList(_usageKey) ?? <String>[];
    counts.add(key);
    await prefs.setStringList(_usageKey, counts);

    final timestamps = prefs.getStringList(_timestampKey) ?? <String>[];
    timestamps.add('$key=${DateTime.now().toIso8601String()}');
    await prefs.setStringList(_timestampKey, timestamps);
  }

  DateTime? lastUsedAt(String pairKey) {
    final timestamps = prefs.getStringList(_timestampKey);
    if (timestamps == null) return null;
    final entry = timestamps.where(
      (t) => t.startsWith('$pairKey='),
    ).lastOrNull;
    if (entry == null) return null;
    return DateTime.tryParse(entry.substring(pairKey.length + 1));
  }
}
