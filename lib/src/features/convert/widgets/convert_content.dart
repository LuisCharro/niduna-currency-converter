import 'package:flutter/material.dart';

import '../domain/convert_state.dart';
import 'amount_panel.dart';
import 'currency_picker_sheet.dart';
import 'rates_section_header.dart';
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AmountPanel(
          isRefreshing: widget.state.isRefreshing,
          lastUpdatedLabel: widget.state.lastUpdatedLabel,
          nextUpdateLabel: widget.state.nextUpdateLabel,
          status: widget.state.status,
          amountText: widget.state.amountText,
          base: widget.state.base,
          onRefresh: widget.onRefresh,
          onMore: widget.onMore,
          onAmountChanged: widget.onAmountChanged,
          onBaseTap: () => _openPicker(context, selectBaseMode: true),
        ),
        RatesSectionHeader(
          onEdit: () => _openPicker(context, selectBaseMode: false),
        ),
        Expanded(
          child: VisibleRatesList(
            quotes: widget.state.quotes,
            base: widget.state.base,
            amount: double.tryParse(widget.state.amountText) ?? 0,
            onAmountChanged: widget.onAmountChanged,
            onRefresh: widget.onRefresh,
            onSetBase: widget.onSelectBase,
            onRemove: widget.onToggleCode,
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
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
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
