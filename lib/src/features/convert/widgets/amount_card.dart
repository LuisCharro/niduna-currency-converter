import 'package:flutter/material.dart';

import 'amount_panel.dart';

class AmountCard extends StatelessWidget {
  const AmountCard({
    required this.lastUpdatedLabel,
    required this.amountText,
    required this.base,
    required this.onAmountChanged,
    required this.onBaseTap,
    super.key,
  });

  final String lastUpdatedLabel;
  final String amountText;
  final String base;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onBaseTap;

  @override
  Widget build(BuildContext context) {
    return AmountPanel(
      lastUpdatedLabel: lastUpdatedLabel,
      amountText: amountText,
      base: base,
      onAmountChanged: onAmountChanged,
      onBaseTap: onBaseTap,
    );
  }
}
