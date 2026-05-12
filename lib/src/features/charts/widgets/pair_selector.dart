import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: _CurrencyPill(
            code: base,
            onTap: () => _openPicker(context, selectingBase: true),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onSwap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.card,
              border: Border.all(color: AppTheme.border.withValues(alpha: .4)),
              boxShadow: AppTheme.subtleShadow,
            ),
            child: Icon(
              Icons.swap_vert_rounded,
              color: AppTheme.text,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CurrencyPill(
            code: quote,
            onTap: () => _openPicker(context, selectingBase: false),
          ),
        ),
      ],
    );
  }

  Future<void> _openPicker(
    BuildContext context, {
    required bool selectingBase,
  }) async {
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

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({required this.code, required this.onTap});

  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(code);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border.withValues(alpha: .4)),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CurrencyFlagIcon(code: code, symbol: currency.symbol, radius: 14),
            const SizedBox(width: 8),
            Text(
              code,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
