import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/convert_state.dart';
import 'amount_card.dart';
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
    final visibleCodes = widget.state.quotes.map((quote) => quote.code).toSet();
    if (_activeCode != null && !visibleCodes.contains(_activeCode)) {
      _activeCode = null;
    }
    return Column(
      children: <Widget>[
        AmountCard(
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
        _RatesToolbar(
          count: widget.state.selectedCodes.length,
          onEdit: () => _openPicker(context, selectBaseMode: false),
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

class _RatesToolbar extends StatelessWidget {
  const _RatesToolbar({required this.count, required this.onEdit});

  final int count;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Converted to',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$count currencies',
                  style: AppTheme.caption.copyWith(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Add'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              backgroundColor: AppTheme.container.withValues(alpha: .48),
              minimumSize: const Size(66, 38),
              padding: const EdgeInsets.symmetric(horizontal: 11),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
