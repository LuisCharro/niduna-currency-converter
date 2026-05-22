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
    final style = AppTheme.heroAmountFor(context).copyWith(
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: Text(
                display,
                key: ValueKey<String>(display),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAmountSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.card,
      builder: (context) => AmountInputSheet(
        amountText: amountText,
        base: base,
        onAmountChanged: onAmountChanged,
      ),
    );
  }
}
