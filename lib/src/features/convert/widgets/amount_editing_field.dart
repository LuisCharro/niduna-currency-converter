import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_input_sheet.dart';

class AmountEditingField extends StatelessWidget {
  const AmountEditingField({
    required this.amountText,
    required this.base,
    required this.onAmountChanged,
    super.key = const Key('convert_amount_field'),
  });

  final String amountText;
  final String base;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final display = amountText.isEmpty ? '0.00' : amountText;
    final baseStyle = AppTheme.heroAmountFor(context).copyWith(
      color: amountText.isEmpty ? AppTheme.muted : AppTheme.text,
    );

    return Semantics(
      button: true,
      label: 'Edit amount, currently ${amountText.isEmpty ? '0' : amountText}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openAmountSheet(context),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.centerLeft,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = _adaptiveStyleForWidth(
                  display, baseStyle, constraints.maxWidth,
                );
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
          ),
        ),
      ),
    );
  }

  TextStyle _adaptiveStyleForWidth(
    String text,
    TextStyle baseStyle,
    double maxWidth,
  ) {
    for (final fontSize in AppTheme.heroAmountSizes) {
      if (fontSize < baseStyle.fontSize!) break;
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
    return baseStyle.copyWith(fontSize: AppTheme.heroAmountSizes.last);
  }

  Future<void> _openAmountSheet(BuildContext context) async {
    final nextAmount = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.card,
      barrierColor: Colors.black.withValues(alpha: .36),
      builder: (context) => AmountInputSheet(
        amountText: amountText,
        base: base,
      ),
    );
    if (nextAmount != null) {
      onAmountChanged(nextAmount);
    }
  }
}
