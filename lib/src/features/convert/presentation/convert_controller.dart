import 'package:flutter/foundation.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/rates/rate_refresh_policy.dart';
import '../../favorites/data/favorites_store.dart';
import '../../favorites/domain/favorite_pair.dart';
import '../data/latest_rates_repository.dart';
import '../domain/convert_quote_builder.dart';
import '../domain/convert_state.dart';
import '../domain/latest_rates_snapshot.dart';
import '../domain/rate_freshness.dart';
import '../models/currency_quote.dart';

part 'convert_controller_editing.dart';
part 'convert_controller_loading.dart';

class ConvertController extends ChangeNotifier {
  ConvertController({
    required ConvertRatesRepository repository,
    FavoritesStore? favoritesStore,
    AppPreferences? preferences,
    String defaultBase = 'USD',
    double amount = 100,
    List<String>? selectedCodes,
    int decimalPlaces = 2,
  }) : _repository = repository,
       _favoritesStore = favoritesStore,
       _preferences = preferences {
    _decimalPlaces = decimalPlaces;
    configure(base: defaultBase, amount: amount, selectedCodes: selectedCodes);
    _favoritesStore?.addListener(_onFavoritesChanged);
  }

  final ConvertRatesRepository _repository;
  final FavoritesStore? _favoritesStore;
  final AppPreferences? _preferences;
  String _base = 'USD';
  double _amount = 100;
  String _amountText = '100.00';
  List<String> _selectedCodes = <String>['EUR', 'GBP', 'JPY'];
  Set<String> _hiddenCryptoCodes = <String>{};
  LatestRatesSnapshot? _snapshot;
  int _decimalPlaces = 2;

  ConvertState state = ConvertState.loading();
  LatestRatesSnapshot? get snapshot => _snapshot;
  List<FavoritePair> get favoritePairs =>
      _favoritesStore?.pairs ?? const <FavoritePair>[];
  bool get maxFavoritesReached => _favoritesStore?.isFull ?? false;
  bool _disposed = false;

  void configure({
    required String base,
    required double amount,
    List<String>? selectedCodes,
  }) {
    _base = base;
    _amount = amount;
    _amountText = amount.toStringAsFixed(2);
    _selectedCodes = List<String>.from(
      selectedCodes ?? <String>['EUR', 'GBP', 'JPY'],
    )..remove(base);
    state = ConvertState.loading().copyWith(
      base: _base,
      amountText: _amountText,
      selectedCodes: _selectedCodes,
    );
  }

  void setDecimalPlaces(int value) {
    if (value < 2 || value > 6) return;
    _decimalPlaces = value;
    if (_snapshot != null) {
      state = _stateFromSnapshot(_snapshot!, state.status);
      _safeNotify();
    }
  }

  @override
  void dispose() {
    _favoritesStore?.removeListener(_onFavoritesChanged);
    _disposed = true;
    super.dispose();
  }

  bool isFavorite(String quote) {
    return _favoritesStore?.isFavorite(_base, quote) ?? false;
  }

  Future<void> toggleFavorite(String quote) async {
    await _favoritesStore?.toggle(_base, quote);
  }

  Future<bool> tryToggleFavorite(String quote) async {
    final store = _favoritesStore;
    if (store == null) return true;
    if (!store.canAdd(_base, quote)) return false;
    await store.toggle(_base, quote);
    return true;
  }

  Future<void> removeFavoritePair(FavoritePair pair) async {
    await _favoritesStore?.remove(pair.base, pair.quote);
  }

  Future<void> openFavoritePair(FavoritePair pair) async {
    if (pair.base != _base) {
      await setBase(pair.base);
    }
    if (!_selectedCodes.contains(pair.quote)) {
      _selectedCodes = <String>[
        pair.quote,
        ..._selectedCodes.where(
          (code) => code != pair.base && code != pair.quote,
        ),
      ];
      _preferences?.setSelectedCodes(_selectedCodes);
      state = _snapshot == null
          ? state.copyWith(selectedCodes: _selectedCodes)
          : _stateFromSnapshot(_snapshot!, state.status);
      _safeNotify();
    }
  }

  void _onFavoritesChanged() {
    if (_snapshot == null) return;
    state = _stateFromSnapshot(_snapshot!, state.status);
    _safeNotify();
  }

  Set<String> _favoriteQuotes() {
    final store = _favoritesStore;
    if (store == null) return <String>{};
    return store.pairs
        .where((p) => p.base == _base)
        .map((p) => p.quote)
        .toSet();
  }

  ConvertState _stateFromSnapshot(
    LatestRatesSnapshot snapshot,
    ConvertStatus status,
  ) {
    _snapshot = snapshot;
    final favQuotes = _favoriteQuotes();
    return ConvertState(
      status: status,
      quotes:
          buildQuotes(
            snapshot: snapshot,
            amount: _amount,
            decimalPlaces: _decimalPlaces,
            quoteCodes: _selectedCodes,
            excludeCodes: _hiddenCryptoCodes,
          ).map((q) {
            final isFav = favQuotes.contains(q.code);
            return CurrencyQuote(
              q.symbol,
              q.code,
              q.name,
              q.amount,
              q.rateLine,
              rate: q.rate,
              favorite: isFav,
            );
          }).toList(),
      lastUpdatedLabel: _formatUpdated(snapshot),
      nextUpdateLabel: RateFreshness.nextUpdateLabel(),
      base: _base,
      amountText: _amountText,
      selectedCodes: List<String>.unmodifiable(_selectedCodes),
    );
  }

  String _formatUpdated(LatestRatesSnapshot snapshot) {
    return RateFreshness.updatedLabel(
      rateDate: snapshot.date,
      savedAt: snapshot.savedAt,
    );
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
