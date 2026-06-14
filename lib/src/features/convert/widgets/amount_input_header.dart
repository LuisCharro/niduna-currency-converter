import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'amount_display_text.dart';
import 'currency_chip.dart';

class AmountInputHeader extends StatelessWidget {
  const AmountInputHeader({
    required this.amount,
    required this.currency,
    required this.base,
    required this.onCancel,
    this.expression = '',
    super.key,
  });

  final String amount;
  final SupportedCurrency currency;
  final String base;
  final VoidCallback onCancel;

  /// Running calculator expression (e.g. "100 + 50"); empty when none.
  final String expression;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              l10n?.amountSheetTitle ?? "Edit amount",
              style: AppTheme.caption.copyWith(color: colors.muted),
            ),
            const Spacer(),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: colors.muted,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n?.btnCancel ?? "Cancel"),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 16,
          child: expression.isEmpty
              ? null
              : Text(
                  expression,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption.copyWith(
                    color: colors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        AdaptiveAmountText(
          display: '${currency.symbol} ${amount.isEmpty ? '0' : amount}',
        ),
        const SizedBox(height: 10),
        CurrencyChip(currency: currency, base: base),
        const SizedBox(height: 14),
        Divider(color: colors.border.withValues(alpha: .12), height: 1),
        const SizedBox(height: 14),
        Text(
          l10n?.quickAmounts ?? "Quick amounts",
          style: AppTheme.caption.copyWith(color: colors.muted),
        ),
      ],
    );
  }
}
