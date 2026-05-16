import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_input_sheet.dart';

class AmountEditingField extends StatelessWidget {
  const AmountEditingField({
    required this.amountText,
    required this.base,
    required this.onAmountChanged,
    super.key,
  });

  final String amountText;
  final String base;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Edit amount, currently ${amountText.isEmpty ? '0' : amountText}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          onTap: () => _openAmountSheet(context),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              amountText.isEmpty ? '0.00' : amountText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: amountText.isEmpty ? AppTheme.muted : AppTheme.text,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.05,
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
