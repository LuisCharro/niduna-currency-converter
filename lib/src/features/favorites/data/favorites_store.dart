import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/currency/currency_code_migration.dart';
import '../../../core/currency/supported_currencies.dart';
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
    final pair = _canonicalPair(base, quote);
    return pair != null && _pairs.contains(pair);
  }

  bool canAdd(String base, String quote, int limit) =>
      isFavorite(base, quote) || _pairs.length < limit;

  Future<void> toggle(String base, String quote) async =>
      isFavorite(base, quote)
      ? await remove(base, quote)
      : await add(base, quote);

  Future<void> add(String base, String quote) async {
    final pair = _canonicalPair(base, quote);
    if (pair == null || _pairs.contains(pair)) return;
    _pairs = [..._pairs, pair];
    _save();
    notifyListeners();
  }

  Future<void> remove(String base, String quote) async {
    final pair = _canonicalPair(base, quote);
    if (pair == null) return;
    _pairs = _pairs.where((candidate) => candidate != pair).toList();
    _save();
    notifyListeners();
  }

  /// Moves the favorite at [oldIndex] to [newIndex] and persists the new order.
  /// [newIndex] follows the ReorderableListView convention (it can be
  /// `length`, meaning "after the last item").
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _pairs.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > _pairs.length - 1) target = _pairs.length - 1;
    if (target == oldIndex) return;
    final next = <FavoritePair>[..._pairs];
    final moved = next.removeAt(oldIndex);
    next.insert(target, moved);
    _pairs = next;
    _save();
    notifyListeners();
  }

  void _save() {
    _prefs.setStringList(_key, _pairs.map((p) => p.toKey()).toList());
  }

  void _load() {
    final keys = _prefs.getStringList(_key);
    if (keys == null) return;
    final seen = <FavoritePair>{};
    _pairs = keys
        .map(tryParse)
        .whereType<FavoritePair>()
        .where(seen.add)
        .toList();
    final canonical = _pairs.map((pair) => pair.toKey()).toList();
    // Persist the canonicalised form so the next load is a no-op.
    if (!_listEquals(canonical, keys)) {
      _save();
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static FavoritePair? tryParse(String key) {
    try {
      final canonical = canonicalizeFavoriteKey(key);
      if (canonical == null) return null;
      final pair = FavoritePair.fromKey(canonical);
      return _canonicalPair(pair.base, pair.quote);
    } catch (_) {
      return null;
    }
  }

  static FavoritePair? _canonicalPair(String rawBase, String rawQuote) {
    final base = canonicalCurrencyCode(rawBase);
    final quote = canonicalCurrencyCode(rawQuote);
    if (base == quote ||
        !isSupportedCurrencyCode(base) ||
        !isSupportedCurrencyCode(quote)) {
      return null;
    }
    return FavoritePair(base: base, quote: quote);
  }

  Future<void> seedStarterIfEmpty() async {
    if (_pairs.isNotEmpty) return;
    final alreadySeeded = _prefs.getBool('starter_favorites_seeded') ?? false;
    if (alreadySeeded) return;

    _pairs.add(FavoritePair(base: 'USD', quote: 'EUR'));
    _pairs.add(FavoritePair(base: 'USD', quote: 'GBP'));
    _pairs.add(FavoritePair(base: 'USD', quote: 'BTC'));

    await _persist();
    await _prefs.setBool('starter_favorites_seeded', true);
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(_key, _pairs.map((p) => p.toKey()).toList());
  }
}
