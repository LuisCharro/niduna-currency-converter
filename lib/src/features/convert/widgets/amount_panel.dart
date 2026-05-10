import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_value_row.dart';
import 'convert_label.dart';

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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .65)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ConvertLabel('YOU SEND'),
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: AppTheme.muted),
                  const SizedBox(width: 4),
                  ConvertLabel(lastUpdatedLabel),
                  const SizedBox(width: 6),
                  Tooltip(
                    message:
                        'Rates update once per day from the European Central Bank',
                    child: Icon(Icons.info_outline,
                        size: 14, color: AppTheme.subtle),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
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
