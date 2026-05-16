part of 'convert_controller.dart';

extension ConvertControllerLoading on ConvertController {
  Future<void> load() async {
    if (state.base != _base) {
      configure(base: _base, amount: _amount, selectedCodes: _selectedCodes);
    }
    final cached = await _repository.readCached(_base);
    if (cached != null) {
      state = _stateFromSnapshot(cached, ConvertStatus.cached);
      _safeNotify();
    }
    await refresh(hasCached: cached != null);
  }

  Future<void> refresh({bool hasCached = false}) async {
    if (state.hasQuotes) {
      state = state.copyWith(status: ConvertStatus.refreshing);
      _safeNotify();
    }

    try {
      final fresh = await _repository.fetchLatest(_base);
      state = _stateFromSnapshot(fresh, ConvertStatus.fresh);
    } catch (_) {
      state = state.hasQuotes || hasCached
          ? state.copyWith(
              status: ConvertStatus.stale,
              message: 'Network unavailable. Showing cached rates.',
            )
          : state.copyWith(
              status: ConvertStatus.noCache,
              quotes: const <CurrencyQuote>[],
              lastUpdatedLabel: 'No cached rates',
              nextUpdateLabel: 'Connect to refresh daily rates',
              message: 'Connect to the internet to load rates.',
            );
    }
    _safeNotify();
  }
}
