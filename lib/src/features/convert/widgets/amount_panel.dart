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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.card.withValues(alpha: .78),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border.withValues(alpha: .1)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 9, 16, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.schedule, size: 11, color: AppTheme.muted),
                  const SizedBox(width: 4),
                  Text(
                    lastUpdatedLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message:
                        'Rates update once per day from the European Central Bank',
                    child: Icon(
                      Icons.info_outline,
                      size: 12,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              AmountValueRow(
                amountText: amountText,
                base: base,
                onAmountChanged: onAmountChanged,
                onBaseTap: onBaseTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
