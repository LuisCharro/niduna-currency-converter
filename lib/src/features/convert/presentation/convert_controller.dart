import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/latest_rates_repository.dart';
import '../domain/convert_quote_builder.dart';
import '../domain/convert_state.dart';
import '../domain/latest_rates_snapshot.dart';
import '../models/currency_quote.dart';

class ConvertController extends ChangeNotifier {
  ConvertController({
    required ConvertRatesRepository repository,
    this.base = 'USD',
    this.amount = 100,
  }) : _repository = repository;

  final ConvertRatesRepository _repository;
  final String base;
  final double amount;

  ConvertState state = ConvertState.loading();
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    final cached = await _repository.readCached(base);
    if (cached != null) {
      state = _stateFromSnapshot(cached, ConvertStatus.cached);
      _safeNotify();
    }
    await refresh(hasCached: cached != null);
  }

  Future<void> refresh({bool hasCached = false}) async {
    if (state.hasQuotes) {
      state = ConvertState(
        status: ConvertStatus.refreshing,
        quotes: state.quotes,
        lastUpdatedLabel: state.lastUpdatedLabel,
      );
      _safeNotify();
    }

    try {
      final fresh = await _repository.fetchLatest(base);
      state = _stateFromSnapshot(fresh, ConvertStatus.fresh);
    } catch (_) {
      if (state.hasQuotes || hasCached) {
        state = ConvertState(
          status: ConvertStatus.stale,
          quotes: state.quotes,
          lastUpdatedLabel: state.lastUpdatedLabel,
          message: 'Network unavailable. Showing cached rates.',
        );
      } else {
        state = const ConvertState(
          status: ConvertStatus.noCache,
          quotes: <CurrencyQuote>[],
          lastUpdatedLabel: 'No cached rates',
          message: 'Connect to the internet to load rates.',
        );
      }
    }
    _safeNotify();
  }

  ConvertState _stateFromSnapshot(
    LatestRatesSnapshot snapshot,
    ConvertStatus status,
  ) {
    return ConvertState(
      status: status,
      quotes: buildQuotes(snapshot: snapshot, amount: amount),
      lastUpdatedLabel: _formatUpdated(snapshot),
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
