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
    if (_selectedCodes.contains(code)) {
      if (_selectedCodes.length == 1) {
        return;
      }
      _selectedCodes = _selectedCodes.where((value) => value != code).toList();
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
