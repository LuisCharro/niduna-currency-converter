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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: AppTheme.border.withValues(alpha: .15)),
            ),
            margin: EdgeInsets.zero,
            color: AppTheme.card,
            shadowColor: Colors.black.withValues(alpha: .04),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.schedule, size: 11, color: AppTheme.subtle.withValues(alpha: .6)),
                      const SizedBox(width: 4),
                      Text(
                        lastUpdatedLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.subtle.withValues(alpha: .6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Rates update once per day from the European Central Bank',
                        child: Icon(
                          Icons.info_outline,
                          size: 12,
                          color: AppTheme.subtle.withValues(alpha: .5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
          Positioned(
            left: 18,
            right: 18,
            top: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.trendUp.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
