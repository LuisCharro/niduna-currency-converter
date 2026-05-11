import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_value_row.dart';

class AmountPanel extends StatelessWidget {
  const AmountPanel({
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.schedule, size: 12, color: AppTheme.subtle),
              const SizedBox(width: 4),
              Text(
                lastUpdatedLabel,
                style: AppTheme.micro.copyWith(color: AppTheme.subtle),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    'Rates update once per day from the European Central Bank',
                child: Icon(Icons.info_outline,
                    size: 13, color: AppTheme.subtle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AmountValueRow(
            amountText: amountText,
            base: base,
            onAmountChanged: onAmountChanged,
            onBaseTap: onBaseTap,
          ),
        ],
      ),
    );
  }
}
