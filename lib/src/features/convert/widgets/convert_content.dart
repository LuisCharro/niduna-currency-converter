import 'package:flutter/material.dart';

import '../domain/convert_state.dart';
import 'amount_card.dart';
import 'convert_header.dart';
import 'currency_picker_sheet.dart';
import 'rates_status_card.dart';
import 'visible_rates_sliver.dart';
import 'visible_rates_toolbar.dart';

class ConvertContent extends StatelessWidget {
  const ConvertContent({
    required this.state,
    required this.onRefresh,
    required this.onAmountChanged,
    required this.onSelectBase,
    required this.onSwap,
    required this.onToggleCode,
    super.key,
  });

  final ConvertState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onSelectBase;
  final VoidCallback onSwap;
  final ValueChanged<String> onToggleCode;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: ConvertHeader(
            isRefreshing: state.isRefreshing,
            onRefresh: () => onRefresh(),
          ),
        ),
        SliverToBoxAdapter(
          child: AmountCard(
            lastUpdatedLabel: state.lastUpdatedLabel,
            amountText: state.amountText,
            base: state.base,
            onAmountChanged: onAmountChanged,
            onBaseTap: () => _openPicker(context, selectBaseMode: true),
            onSwap: onSwap,
          ),
        ),
        SliverToBoxAdapter(
          child: RatesStatusCard(
            label: state.statusLabel,
            message: state.message,
            showRetry: state.status == ConvertStatus.noCache,
            onRetry: () => onRefresh(),
          ),
        ),
        SliverToBoxAdapter(
          child: VisibleRatesToolbar(
            count: state.selectedCodes.length,
            onEdit: () => _openPicker(context, selectBaseMode: false),
          ),
        ),
        VisibleRatesSliver(quotes: state.quotes, onRemove: onToggleCode),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  void _openPicker(BuildContext context, {required bool selectBaseMode}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => CurrencyPickerSheet(
        title: selectBaseMode ? 'Base currency' : 'Visible currencies',
        base: state.base,
        selectedCodes: state.selectedCodes,
        selectBaseMode: selectBaseMode,
        onSelectBase: (code) {
          Navigator.pop(context);
          onSelectBase(code);
        },
        onToggleCode: onToggleCode,
      ),
    );
  }
}
