import 'package:flutter/material.dart';

import 'amount_editing_field.dart';

class AmountValueRow extends StatelessWidget {
  const AmountValueRow({
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
    return AmountEditingField(
      amountText: amountText,
      base: base,
      onAmountChanged: onAmountChanged,
    );
  }
}
