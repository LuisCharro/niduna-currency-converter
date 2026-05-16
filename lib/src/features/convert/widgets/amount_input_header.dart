import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class AmountInputHeader extends StatelessWidget {
  const AmountInputHeader({
    required this.amount,
    required this.currency,
    required this.base,
    super.key,
  });

  final String amount;
  final SupportedCurrency currency;
  final String base;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.container.withValues(alpha: .52),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Amount',
                  style: AppTheme.caption.copyWith(color: AppTheme.muted),
                ),
                const Spacer(),
                _CurrencyChip(currency: currency, base: base),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${currency.symbol} ${amount.isEmpty ? '0' : amount}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AmountSheetHandle extends StatelessWidget {
  const AmountSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.border.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const SizedBox(width: 44, height: 4),
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({required this.currency, required this.base});

  final SupportedCurrency currency;
  final String base;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CurrencyFlagIcon(code: base, symbol: currency.symbol, radius: 11),
          const SizedBox(width: 6),
          Text(base, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
