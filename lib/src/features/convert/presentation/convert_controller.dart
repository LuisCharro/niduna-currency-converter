import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../favorites/data/favorites_store.dart';
import '../data/latest_rates_repository.dart';
import '../domain/convert_quote_builder.dart';
import '../domain/convert_state.dart';
import '../domain/latest_rates_snapshot.dart';
import '../models/currency_quote.dart';

part 'convert_controller_editing.dart';
part 'convert_controller_loading.dart';

class ConvertController extends ChangeNotifier {
  ConvertController({
    required ConvertRatesRepository repository,
    FavoritesStore? favoritesStore,
    String base = 'USD',
    double amount = 100,
    List<String>? selectedCodes,
  }) : _repository = repository,
       _favoritesStore = favoritesStore {
    configure(base: base, amount: amount, selectedCodes: selectedCodes);
    _favoritesStore?.addListener(_onFavoritesChanged);
  }

  final ConvertRatesRepository _repository;
  final FavoritesStore? _favoritesStore;
  String _base = 'USD';
  double _amount = 100;
  String _amountText = '100.00';
  List<String> _selectedCodes = <String>['CHF', 'EUR', 'GBP', 'JPY'];
  LatestRatesSnapshot? _snapshot;

  ConvertState state = ConvertState.loading();
  LatestRatesSnapshot? get snapshot => _snapshot;
  bool get maxFavoritesReached =>
      _favoritesStore?.isFull ?? false;
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
      selectedCodes ?? <String>['CHF', 'EUR', 'GBP', 'JPY'],
    )..remove(base);
    state = ConvertState.loading().copyWith(
      base: _base,
      amountText: _amountText,
      selectedCodes: _selectedCodes,
    );
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
      quotes: buildQuotes(
        snapshot: snapshot,
        amount: _amount,
        quoteCodes: _selectedCodes,
      ).map((q) {
        final isFav = favQuotes.contains(q.code);
        return CurrencyQuote(
          q.symbol, q.code, q.name, q.amount, q.rateLine,
          favorite: isFav,
        );
      }).toList(),
      lastUpdatedLabel: _formatUpdated(snapshot),
      base: _base,
      amountText: _amountText,
      selectedCodes: List<String>.unmodifiable(_selectedCodes),
    );
  }

  String _formatUpdated(LatestRatesSnapshot snapshot) {
    final date = snapshot.date ?? snapshot.savedAt;
    return 'Updated: ${DateFormat('MMM d, HH:mm').format(date)}';
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
