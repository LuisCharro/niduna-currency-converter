import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../data/convert_row_hint_store.dart';
import '../domain/convert_state.dart';
import 'amount_panel.dart';
import 'convert_row_actions_hint.dart';
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
    required this.onShare,
    this.maxFavoritesReached = false,
    this.decimalPlaces = 2,
    this.hintStore,
    super.key,
  });

  final ConvertState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onSelectBase;
  final ValueChanged<String> onToggleCode;
  final Future<bool> Function(String code) onToggleFavorite;
  final VoidCallback onMore;
  final VoidCallback? onShare;
  final bool maxFavoritesReached;
  final int decimalPlaces;

  /// Persists whether the one-time row-actions hint has been dismissed or
  /// already earned (by successfully opening the lens once). Null disables
  /// the hint entirely (e.g. in tests that don't wire persistence).
  final ConvertRowHintStore? hintStore;

  @override
  State<ConvertContent> createState() => _ConvertContentState();
}

class _ConvertContentState extends State<ConvertContent> {
  late bool _hintVisible = !(widget.hintStore?.seen ?? true);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 700;
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
          onShare: widget.onShare,
          onMore: widget.onMore,
          onAmountChanged: widget.onAmountChanged,
          onBaseTap: () => _openPicker(context, selectBaseMode: true),
          compact: compact,
        ),
        RatesSectionHeader(
          onEdit: () => _openPicker(context, selectBaseMode: false),
          compact: compact,
        ),
        if (_hintVisible) ConvertRowActionsHint(onDismiss: _dismissHint),
        Expanded(
          child: VisibleRatesList(
            quotes: widget.state.quotes,
            base: widget.state.base,
            amount: double.tryParse(widget.state.amountText) ?? 0,
            decimalPlaces: widget.decimalPlaces,
            onAmountChanged: widget.onAmountChanged,
            onRefresh: widget.onRefresh,
            onSetBase: widget.onSelectBase,
            onRemove: widget.onToggleCode,
            onToggleFavorite: widget.onToggleFavorite,
            maxFavoritesReached: widget.maxFavoritesReached,
            onLensOpened: _dismissHint,
          ),
        ),
      ],
    );
  }

  void _dismissHint() {
    if (!_hintVisible) return;
    setState(() => _hintVisible = false);
    widget.hintStore?.markSeen();
  }

  void _openPicker(BuildContext context, {required bool selectBaseMode}) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => CurrencyPickerSheet(
        title: selectBaseMode
            ? l10n?.selectBaseCurrency ?? 'Select base currency'
            : l10n?.addCurrenciesTitle ?? 'Visible currencies',
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
