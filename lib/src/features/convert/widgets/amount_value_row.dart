import 'package:flutter/material.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: AmountEditingField(
            amountText: amountText,
            base: base,
            onAmountChanged: onAmountChanged,
          ),
        ),
        const SizedBox(width: 12),
        AmountBaseButton(base: base, onTap: onBaseTap),
      ],
    );
  }
}
