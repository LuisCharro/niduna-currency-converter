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
        color: AppTheme.card.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 50, minWidth: 76),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              border: Border.all(color: AppTheme.border.withValues(alpha: .18)),
              boxShadow: AppTheme.subtleShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CurrencyFlagIcon(
                  code: base,
                  symbol: currency.symbol,
                  radius: 13,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
