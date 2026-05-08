import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_value_row.dart';
import 'convert_label.dart';

class AmountPanel extends StatelessWidget {
  const AmountPanel({super.key});

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
      child: const Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ConvertLabel('YOU SEND'),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule, size: 13, color: AppTheme.muted),
                  SizedBox(width: 4),
                  ConvertLabel('Updated: Today, 09:00'),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          AmountValueRow(),
        ],
      ),
    );
  }
}
