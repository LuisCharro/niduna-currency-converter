part of 'convert_controller.dart';

extension ConvertControllerEditing on ConvertController {
  Future<void> setBase(String code) async {
    if (code == _base) {
      return;
    }
    final previousBase = _base;
    _base = code;
    _selectedCodes = <String>[
      previousBase,
      ..._selectedCodes.where((selected) => selected != code),
    ];
    _preferences?.setSelectedCodes(_selectedCodes);
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

    final rates = <String, double>{
      current.base: 1 / baseRate,
    };
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
    if (code == _base) {
      return;
    }
    final isCrypto = isCryptoCurrency(code);
    if (_selectedCodes.contains(code)) {
      if (_selectedCodes.length == 1) {
        return;
      }
      _selectedCodes = _selectedCodes.where((value) => value != code).toList();
      if (isCrypto) {
        _hiddenCryptoCodes = <String>{..._hiddenCryptoCodes, code};
      }
    } else if (_hiddenCryptoCodes.contains(code)) {
      _hiddenCryptoCodes = _hiddenCryptoCodes.where((c) => c != code).toSet();
      _selectedCodes = <String>[..._selectedCodes, code];
    } else if (isCrypto && _snapshot?.rates.containsKey(code) == true) {
      _hiddenCryptoCodes = <String>{..._hiddenCryptoCodes, code};
    } else {
      _selectedCodes = <String>[..._selectedCodes, code];
    }
    _preferences?.setSelectedCodes(_selectedCodes);
    state = _snapshot == null
        ? state.copyWith(selectedCodes: _selectedCodes)
        : _stateFromSnapshot(_snapshot!, state.status);
    _safeNotify();
  }
}
