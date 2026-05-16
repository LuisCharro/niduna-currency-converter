import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/convert_state.dart';
import 'amount_status_bar.dart';
import 'amount_value_row.dart';

class AmountPanel extends StatelessWidget {
  const AmountPanel({
    required this.isRefreshing,
    required this.lastUpdatedLabel,
    required this.nextUpdateLabel,
    required this.status,
    required this.amountText,
    required this.base,
    required this.onRefresh,
    required this.onMore,
    required this.onAmountChanged,
    required this.onBaseTap,
    super.key,
  });

  final bool isRefreshing;
  final String lastUpdatedLabel;
  final String nextUpdateLabel;
  final ConvertStatus status;
  final String amountText;
  final String base;
  final Future<void> Function() onRefresh;
  final VoidCallback onMore;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onBaseTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmountStatusBar(
            isRefreshing: isRefreshing,
            lastUpdatedLabel: lastUpdatedLabel,
            nextUpdateLabel: nextUpdateLabel,
            status: status,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Amount',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AmountActionButton(
                tooltip: 'Refresh rates',
                icon: Icons.sync_rounded,
                onPressed: () => onRefresh(),
              ),
              const SizedBox(width: 8),
              AmountActionButton(
                tooltip: 'Settings',
                icon: Icons.tune_rounded,
                onPressed: onMore,
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
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.border.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const SizedBox(height: 1, width: double.infinity),
          ),
        ],
      ),
    );
  }
}
