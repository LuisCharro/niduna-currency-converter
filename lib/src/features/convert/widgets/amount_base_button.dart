import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class AmountBaseButton extends StatelessWidget {
  const AmountBaseButton({required this.base, required this.onTap, super.key});

  final String base;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(base);
    return Semantics(
      button: true,
      label: 'Change base currency, currently $base',
      child: Material(
        color: AppTheme.card.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Container(
              key: ValueKey<String>(base),
              constraints: const BoxConstraints(minHeight: 48, minWidth: 76),
              padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                border: Border.all(color: AppTheme.instrumentBorder(.16)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CurrencyFlagIcon(
                    code: base,
                    symbol: currency.symbol,
                    radius: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    base,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 17,
                    color: AppTheme.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
