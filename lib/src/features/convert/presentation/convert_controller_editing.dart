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
    _snapshot = null;
    state = state.copyWith(
      status: ConvertStatus.loading,
      quotes: const <CurrencyQuote>[],
      base: _base,
      selectedCodes: _selectedCodes,
      lastUpdatedLabel: 'Loading rates',
      message: null,
    );
    _safeNotify();
    await load();
  }

  Future<void> swapWithFirstVisible() async {
    if (_selectedCodes.isEmpty) {
      return;
    }
    await setBase(_selectedCodes.first);
  }

  void setAmountText(String text) {
    _amountText = text;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed != null) {
      _amount = parsed;
    }
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
    state = _snapshot == null
        ? state.copyWith(selectedCodes: _selectedCodes)
        : _stateFromSnapshot(_snapshot!, state.status);
    _safeNotify();
  }
}
