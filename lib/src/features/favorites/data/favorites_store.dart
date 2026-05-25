import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/favorite_pair.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._prefs) {
    _load();
  }

  static const _key = 'favorite_pairs';

  final SharedPreferences _prefs;
  List<FavoritePair> _pairs = <FavoritePair>[];

  List<FavoritePair> get pairs => List.unmodifiable(_pairs);
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
