import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'amount_base_button.dart';
import 'amount_editing_field.dart';

class AmountValueRow extends StatelessWidget {
  const AmountValueRow({
    required this.amountText,
    required this.base,
    required this.onAmountChanged,
    required this.onBaseTap,
    super.key,
  });

  final String amountText;
  final String base;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onBaseTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final display = amountText.isEmpty ? '0.00' : amountText;
    final colors = AppColors.of(context);
    final baseStyle = AppTheme.heroAmountFor(context).copyWith(
      color: amountText.isEmpty ? colors.muted : colors.text,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final inlineWidth = constraints.maxWidth -
            AmountBaseButton.estimatedWidth(compact: true) -
            AppTheme.space3;
        final safeInlineWidth = inlineWidth < 1 ? 1.0 : inlineWidth;
        final inlineStyle = _adaptiveStyleForWidth(
          display,
          baseStyle,
          safeInlineWidth,
        );
        final showsInlineSelector =
            _fitsWidth(display, inlineStyle, safeInlineWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  l10n?.labelAmount.toUpperCase() ?? 'AMOUNT',
                  style: AppTheme.sectionLabel.copyWith(color: colors.muted),
                ),
                if (!showsInlineSelector) ...<Widget>[
                  const Spacer(),
                  AmountBaseButton(
                    base: base,
                    onTap: onBaseTap,
                    compact: true,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.space2),
            if (showsInlineSelector)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: AmountEditingField(
                      amountText: amountText,
                      base: base,
                      onAmountChanged: onAmountChanged,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  AmountBaseButton(
                    base: base,
                    onTap: onBaseTap,
                    compact: true,
                  ),
                ],
              )
            else
              AmountEditingField(
                amountText: amountText,
                base: base,
                onAmountChanged: onAmountChanged,
              ),
          ],
        );
      },
    );
  }

  bool _fitsWidth(String text, TextStyle style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    final fits = painter.didExceedMaxLines == false;
    painter.dispose();
    return fits;
  }

  TextStyle _adaptiveStyleForWidth(
    String text,
    TextStyle baseStyle,
    double maxWidth,
  ) {
    for (final fontSize in AppTheme.heroAmountSizes) {
      if (fontSize < baseStyle.fontSize!) break;
      final candidate = baseStyle.copyWith(fontSize: fontSize);
      if (_fitsWidth(text, candidate, maxWidth)) {
        return candidate;
      }
    }
    return baseStyle.copyWith(fontSize: AppTheme.heroAmountSizes.last);
  }
}
