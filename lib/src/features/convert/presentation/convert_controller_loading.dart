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
    if (!_shouldRefreshOnLoad(cached)) {
      return;
    }
    await refresh(hasCached: cached != null);
  }

  bool _shouldRefreshOnLoad(LatestRatesSnapshot? cached) {
    if (_preferences?.refreshOnOpen == false) {
      return cached == null || _isIncompleteCryptoSnapshot(cached);
    }
    if (cached == null) {
      return true;
    }
    if (_isIncompleteCryptoSnapshot(cached)) {
      return true;
    }
    return RateRefreshPolicy.shouldRefresh(cached.savedAt);
  }

  bool _isIncompleteCryptoSnapshot(LatestRatesSnapshot? snapshot) {
    if (snapshot == null) return false;
    // Only flag as "incomplete" if a SELECTED crypto code is missing from
    // the cache. Checking against all 11 supportedCryptoCurrencies would
    // trigger an unnecessary network fetch whenever the cache has e.g.
    // BTC+ETH but not the other 9 cryptos the user hasn't selected —
    // producing visible network calls on every cold start.
    for (final code in _selectedCodes) {
      if (isCryptoCurrency(code) && !snapshot.rates.containsKey(code)) {
        return true;
      }
    }
    return false;
  }

  Future<void> refresh({bool hasCached = false}) async {
    if (state.hasQuotes) {
      state = state.copyWith(status: ConvertStatus.refreshing);
      _safeNotify();
    }

    try {
      final fresh = await _repository.fetchLatest(_base);
      state = _stateFromSnapshot(fresh, ConvertStatus.fresh);
      _safeNotify();
      unawaited(_enrichWithYesterdayRates(fresh));
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

  Future<void> _enrichWithYesterdayRates(LatestRatesSnapshot today) async {
    try {
      final previousRates = await _repository.fetchYesterdayRates(today.base);
      if (previousRates == null || _disposed) return;
      if (_snapshot != today) return;
      final enriched = LatestRatesSnapshot(
        base: today.base,
        date: today.date,
        savedAt: today.savedAt,
        rates: today.rates,
        previousRates: previousRates,
      );
      state = _stateFromSnapshot(enriched, state.status);
      _safeNotify();
    } catch (_) {}
  }
}
