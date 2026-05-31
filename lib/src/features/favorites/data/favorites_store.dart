import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/favorite_pair.dart';
import 'favorite_usage_tracker.dart';

class FavoritesStore extends ChangeNotifier with FavoriteUsageTracker {
  FavoritesStore(this._prefs) {
    _load();
  }

  static const _key = 'favorite_pairs';

  @override
  SharedPreferences get prefs => _prefs;
  final SharedPreferences _prefs;
  List<FavoritePair> _pairs = <FavoritePair>[];

  List<FavoritePair> get pairs => List.unmodifiable(_pairs);
  List<FavoritePair> get sortedPairs {
    final withUsage = _pairs.map((p) => p.copyWith(
      useCount: usageCount(p.base, p.quote),
      lastUsedAt: lastUsedAt(p.toKey()),
    )).toList();
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

  bool isFavorite(String base, String quote) =>
      _pairs.any((p) => p.base == base && p.quote == quote);

  bool canAdd(String base, String quote, int limit) =>
      isFavorite(base, quote) || _pairs.length < limit;

  Future<void> toggle(String base, String quote) async =>
      isFavorite(base, quote)
          ? await remove(base, quote)
          : await add(base, quote);

  Future<void> add(String base, String quote) async {
    if (isFavorite(base, quote)) return;
    _pairs = [..._pairs, FavoritePair(base: base, quote: quote)];
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

  void _save() {
    _prefs.setStringList(_key, _pairs.map((p) => p.toKey()).toList());
  }

  void _load() {
    final keys = _prefs.getStringList(_key);
    if (keys == null) return;
    _pairs = keys
        .map((k) => tryParse(k))
        .whereType<FavoritePair>()
        .toList();
  }

  static FavoritePair? tryParse(String key) {
    try { return FavoritePair.fromKey(key); } catch (_) { return null; }
  }
}
