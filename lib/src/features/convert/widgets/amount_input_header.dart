import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class AmountInputHeader extends StatelessWidget {
  const AmountInputHeader({
    required this.amount,
    required this.currency,
    required this.base,
    required this.onCancel,
    super.key,
  });

  final String amount;
  final SupportedCurrency currency;
  final String base;
  final VoidCallback onCancel;

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
        LayoutBuilder(
          builder: (context, constraints) {
            final display = '${currency.symbol} ${amount.isEmpty ? '0' : amount}';
            final style = _adaptiveStyleForWidth(display, constraints.maxWidth, context);
            return AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              style: style,
              child: Text(
                display,
                key: ValueKey<String>(display),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _CurrencyChip(currency: currency, base: base),
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

  static const List<double> _sheetAmountSizes = [34.0, 30.0, 26.0, 22.0];

  TextStyle _adaptiveStyleForWidth(String text, double maxWidth, BuildContext context) {
    final colors = AppColors.of(context);
    final baseStyle = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      height: 1.1,
      color: colors.text,
    );
    for (final fontSize in _sheetAmountSizes) {
      if (fontSize > baseStyle.fontSize!) break;
      final candidate = baseStyle.copyWith(fontSize: fontSize);
      final painter = TextPainter(
        text: TextSpan(text: text, style: candidate),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: maxWidth);
      if (painter.didExceedMaxLines == false) {
        painter.dispose();
        return candidate;
      }
      painter.dispose();
    }
    return baseStyle.copyWith(fontSize: _sheetAmountSizes.last);
  }
}

class AmountSheetHandle extends StatelessWidget {
  const AmountSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.border.withValues(alpha: .18),
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
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: colors.border.withValues(alpha: .14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyFlagIcon(code: base, symbol: currency.symbol, radius: 10),
          const SizedBox(width: 5),
          Text(
            base,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
