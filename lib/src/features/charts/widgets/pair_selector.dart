import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'chart_currency_picker_sheet.dart';

class PairSelector extends StatelessWidget {
  const PairSelector({
    required this.base,
    required this.quote,
    required this.onPairChanged,
    required this.onSwap,
    required this.controller,
    super.key,
  });

  final String base;
  final String quote;
  final void Function(String base, String quote) onPairChanged;
  final VoidCallback onSwap;
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _CurrencyButton(
            label: 'Base',
            code: base,
            onTap: () => _openPicker(context, selectingBase: true),
          ),
        ),
        const SizedBox(width: 8),
        _SwapButton(onTap: onSwap),
        const SizedBox(width: 8),
        Expanded(
          child: _CurrencyButton(
            label: 'Quote',
            code: quote,
            onTap: () => _openPicker(context, selectingBase: false),
          ),
        ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context, {required bool selectingBase}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.card,
      builder: (_) => ChartCurrencyPickerSheet(
        title: selectingBase ? 'Select base currency' : 'Select quote currency',
        selectedCode: selectingBase ? base : quote,
        controller: controller,
        baseCurrency: base,
        quoteCurrency: quote,
        selectingBase: selectingBase,
      ),
    );

    if (!context.mounted || selected == null) return;

    final nextBase = selectingBase ? selected : base;
    final nextQuote = selectingBase ? quote : selected;
    if (nextBase == nextQuote) return;

    onPairChanged(nextBase, nextQuote);
  }
}

class _CurrencyButton extends StatelessWidget {
  const _CurrencyButton({
    required this.label,
    required this.code,
    required this.onTap,
  });

  final String label;
  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(code);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppTheme.border.withValues(alpha: .5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Row(
              children: <Widget>[
                Text(
                  code,
                  style: TextStyle(fontSize: 18, color: AppTheme.text, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 6),
                Text(currency.symbol, style: TextStyle(fontSize: 14, color: AppTheme.subtle)),
                const Spacer(),
                Icon(Icons.expand_more, color: AppTheme.muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.container,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Icon(Icons.swap_vert_rounded, color: AppTheme.primary),
        ),
      ),
    );
  }
}
