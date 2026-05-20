import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/convert_state.dart';
import 'amount_header_row.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmountHeaderRow(onRefresh: () => onRefresh(), onMore: onMore),
          const SizedBox(height: 18),
          Text(
            'Amount',
            style: AppTheme.micro.copyWith(
              color: AppTheme.muted,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 4),
          AmountValueRow(
            amountText: amountText,
            base: base,
            onAmountChanged: onAmountChanged,
            onBaseTap: onBaseTap,
          ),
          const SizedBox(height: 12),
          AmountStatusBar(
            isRefreshing: isRefreshing,
            lastUpdatedLabel: lastUpdatedLabel,
            nextUpdateLabel: nextUpdateLabel,
            status: status,
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.border.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const SizedBox(height: 1, width: double.infinity),
          ),
        ],
      ),
    );
  }
}
