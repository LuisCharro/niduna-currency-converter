import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/favorite_pair.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._prefs) {
    _load();
  }

  static const _key = 'favorite_pairs';
  static const _usageKey = 'favorite_usage';
  static const _timestampKey = 'favorite_timestamps';

  final SharedPreferences _prefs;
  List<FavoritePair> _pairs = <FavoritePair>[];

  List<FavoritePair> get pairs => List.unmodifiable(_pairs);
  List<FavoritePair> get sortedPairs {
    final withUsage = _pairs.map((p) {
      final count = usageCount(p.base, p.quote);
      final tsStr = _prefs.getStringList(_timestampKey)?.firstWhere(
        (k) => k == p.toKey(),
        orElse: () => '',
      );
      final lastTs =
          tsStr?.isNotEmpty == true ? DateTime.tryParse(tsStr!) : null;
      return p.copyWith(useCount: count, lastUsedAt: lastTs);
    }).toList();
    withUsage.sort((a, b) {
      final countCmp = b.useCount.compareTo(a.useCount);
      if (countCmp != 0) return countCmp;
      if (a.lastUsedAt == null && b.lastUsedAt == null) return 0;
      if (a.lastUsedAt == null) return 1;
      if (b.lastUsedAt == null) return -1;
      return b.lastUsedAt!.compareTo(a.lastUsedAt!);
    });
    return List.unmodifiable(withUsage);
  }

  bool get isEmpty => _pairs.isEmpty;

  bool isFavorite(String base, String quote) {
    return _pairs.any((p) => p.base == base && p.quote == quote);
  }

  bool canAdd(String base, String quote, int limit) {
    if (isFavorite(base, quote)) return true;
    return _pairs.length < limit;
  }

  Future<void> toggle(String base, String quote) async {
    if (isFavorite(base, quote)) {
      await remove(base, quote);
    } else {
      await add(base, quote);
    }
  }

  Future<void> add(String base, String quote) async {
    if (isFavorite(base, quote)) return;
    _pairs = <FavoritePair>[
      ..._pairs,
      FavoritePair(base: base, quote: quote)
    ];
    _save();
    notifyListeners();
  }

  Future<void> remove(String base, String quote) async {
    _pairs = _pairs
        .where((p) => !(p.base == base && p.quote == quote))
        .toList();
    _save();
    notifyListeners();
  }

  Future<void> recordUsage(String base, String quote) async {
    final key = FavoritePair(base: base, quote: quote).toKey();
    final counts = _prefs.getStringList(_usageKey) ?? <String>[];
    counts.add(key);
    await _prefs.setStringList(_usageKey, counts);

    final timestamps = _prefs.getStringList(_timestampKey) ?? <String>[];
    final now = DateTime.now().toIso8601String();
    timestamps.add('$key=$now');
    await _prefs.setStringList(_timestampKey, timestamps);

    notifyListeners();
  }

  int usageCount(String base, String quote) {
    final key = FavoritePair(base: base, quote: quote).toKey();
    final counts = _prefs.getStringList(_usageKey);
    if (counts == null) return 0;
    return counts.where((k) => k == key).length;
  }

  void _save() {
    final keys = _pairs.map((p) => p.toKey()).toList();
    _prefs.setStringList(_key, keys);
  }

  void _load() {
    final keys = _prefs.getStringList(_key);
    if (keys == null) return;
    _pairs = keys
        .map((k) {
          try {
            return FavoritePair.fromKey(k);
          } catch (_) {
            return null;
          }
        })
        .whereType<FavoritePair>()
        .toList();
  }
}
