import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_panel.dart';

class AmountCard extends StatelessWidget {
  const AmountCard({
    required this.lastUpdatedLabel,
    required this.amountText,
    required this.base,
    required this.onAmountChanged,
    required this.onBaseTap,
    required this.onSwap,
    super.key,
  });

  final String lastUpdatedLabel;
  final String amountText;
  final String base;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onBaseTap;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        AmountPanel(
          lastUpdatedLabel: lastUpdatedLabel,
          amountText: amountText,
          base: base,
          onAmountChanged: onAmountChanged,
          onBaseTap: onBaseTap,
        ),
        Positioned(
          bottom: 0,
          child: FloatingActionButton.small(
            heroTag: 'swap-currencies',
            elevation: 2,
            backgroundColor: AppTheme.card,
            foregroundColor: AppTheme.primary,
            onPressed: onSwap,
            child: const Icon(Icons.swap_vert),
          ),
        ),
      ],
    );
  }
}
