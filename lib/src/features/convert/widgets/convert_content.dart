import 'package:flutter/material.dart';

import '../domain/convert_state.dart';
import 'amount_card.dart';
import 'convert_header.dart';
import 'currency_picker_sheet.dart';
import 'visible_rates_list.dart';

class ConvertContent extends StatefulWidget {
  const ConvertContent({
    required this.state,
    required this.onRefresh,
    required this.onAmountChanged,
    required this.onSelectBase,
    required this.onToggleCode,
    required this.onToggleFavorite,
    required this.onMore,
    this.maxFavoritesReached = false,
    super.key,
  });

  final ConvertState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onSelectBase;
  final ValueChanged<String> onToggleCode;
  final ValueChanged<String> onToggleFavorite;
  final VoidCallback onMore;
  final bool maxFavoritesReached;

  @override
  State<ConvertContent> createState() => _ConvertContentState();
}

class _ConvertContentState extends State<ConvertContent> {
  String? _activeCode;

  @override
  Widget build(BuildContext context) {
    final selectedCodes = widget.state.selectedCodes.toSet();
    if (_activeCode != null && !selectedCodes.contains(_activeCode)) {
      _activeCode = null;
    }
    return Column(
      children: <Widget>[
        ConvertHeader(
          isRefreshing: widget.state.isRefreshing,
          onRefresh: () => widget.onRefresh(),
          onAddCurrencies: () => _openPicker(context, selectBaseMode: false),
          onMore: widget.onMore,
        ),
        AmountCard(
          lastUpdatedLabel: widget.state.lastUpdatedLabel,
          amountText: widget.state.amountText,
          base: widget.state.base,
          onAmountChanged: widget.onAmountChanged,
          onBaseTap: () => _openPicker(context, selectBaseMode: true),
        ),
        Expanded(
          child: VisibleRatesList(
            quotes: widget.state.quotes,
            activeCode: _activeCode,
            onRefresh: widget.onRefresh,
            onSelectCode: (code) => setState(() => _activeCode = code),
            onSetBase: (code) {
              setState(() => _activeCode = null);
              widget.onSelectBase(code);
            },
            onRemove: (code) {
              setState(() => _activeCode = null);
              widget.onToggleCode(code);
            },
            onToggleFavorite: widget.onToggleFavorite,
            maxFavoritesReached: widget.maxFavoritesReached,
          ),
        ),
      ],
    );
  }

  void _openPicker(BuildContext context, {required bool selectBaseMode}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => CurrencyPickerSheet(
        title: selectBaseMode ? 'Base currency' : 'Visible currencies',
        base: widget.state.base,
        selectedCodes: widget.state.selectedCodes,
        selectBaseMode: selectBaseMode,
        onSelectBase: (code) {
          Navigator.pop(context);
          widget.onSelectBase(code);
        },
        onToggleCode: widget.onToggleCode,
      ),
    );
  }
}
