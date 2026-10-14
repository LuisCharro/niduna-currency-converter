part of 'convert_controller.dart';

extension ConvertControllerEditing on ConvertController {
  Future<void> setBase(String code) async {
    if (code == _base) {
      return;
    }
    if (!isSupportedCurrencyCode(code)) return;
    final revision = ++_baseRevision;
    _base = code;
    if (!_currencyCodes.contains(code)) _currencyCodes.add(code);
    _selectedCodes = _currencyCodes
        .where((selected) => selected != code)
        .toList();
    await _preferences?.saveConvertSelection(_base, _currencyCodes);
    if (_disposed || revision != _baseRevision) return;
    final nextSnapshot = _buildSnapshotWithCryptoBase(code);
    if (nextSnapshot != null) {
      state = _stateFromSnapshot(nextSnapshot, state.status);
      _safeNotify();
      return;
    }

    _snapshot = null;
    state = state.copyWith(
      status: ConvertStatus.loading,
      quotes: const <CurrencyQuote>[],
      base: _base,
      selectedCodes: _selectedCodes,
      currencyCodes: List.unmodifiable(_currencyCodes),
      lastUpdatedLabel: 'Loading rates',
      nextUpdateLabel: 'Updates once daily',
      message: null,
    );
    _safeNotify();
    await load();
  }

  LatestRatesSnapshot? _buildSnapshotWithCryptoBase(String code) {
    if (!isCryptoCurrency(code) || _snapshot == null) {
      return null;
    }

    final current = _snapshot!;
    final baseRate = current.rates[code];
    if (baseRate == null || baseRate == 0) {
      return null;
    }

    final rates = <String, double>{current.base: 1 / baseRate};
    for (final entry in current.rates.entries) {
      if (entry.key == code) continue;
      rates[entry.key] = entry.value / baseRate;
    }

    return LatestRatesSnapshot(
      base: code,
      date: current.date,
      savedAt: current.savedAt,
      rates: rates,
    );
  }

  void setAmountText(String text) {
    _amountText = text;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    _amount = parsed ?? (text.trim().isEmpty ? 0 : _amount);
    state = _snapshot == null
        ? state.copyWith(amountText: _amountText)
        : _stateFromSnapshot(_snapshot!, state.status);
    _safeNotify();
  }

  void toggleCode(String code) {
    if (code == _base || !isSupportedCurrencyCode(code)) {
      return;
    }
    if (_selectedCodes.contains(code)) {
      if (_selectedCodes.length == 1) {
        return;
      }
      _selectedCodes = _selectedCodes.where((value) => value != code).toList();
      _currencyCodes.remove(code);
    } else {
      _selectedCodes = <String>[..._selectedCodes, code];
      _currencyCodes.add(code);
    }
    unawaited(
      _preferences?.saveConvertSelection(_base, List.of(_currencyCodes)) ??
          Future<void>.value(),
    );
    state = _snapshot == null
        ? state.copyWith(
            selectedCodes: _selectedCodes,
            currencyCodes: List.unmodifiable(_currencyCodes),
          )
        : _stateFromSnapshot(_snapshot!, state.status);
    _safeNotify();
  }

  void restoreCode(String code, int index) {
    if (!isSupportedCurrencyCode(code) || _currencyCodes.contains(code)) return;
    _currencyCodes.insert(index.clamp(0, _currencyCodes.length), code);
    _selectedCodes = _currencyCodes.where((code) => code != _base).toList();
    unawaited(
      _preferences?.saveConvertSelection(_base, List.of(_currencyCodes)) ??
          Future<void>.value(),
    );
    state = _snapshot == null
        ? state.copyWith(
            selectedCodes: _selectedCodes,
            currencyCodes: List.unmodifiable(_currencyCodes),
          )
        : _stateFromSnapshot(_snapshot!, state.status);
    _safeNotify();
  }
}
