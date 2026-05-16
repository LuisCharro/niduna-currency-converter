import 'package:flutter/material.dart';

import '../domain/convert_state.dart';
import 'amount_panel.dart';

class AmountCard extends StatelessWidget {
  const AmountCard({
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
    return AmountPanel(
      isRefreshing: isRefreshing,
      lastUpdatedLabel: lastUpdatedLabel,
      nextUpdateLabel: nextUpdateLabel,
      status: status,
      amountText: amountText,
      base: base,
      onRefresh: onRefresh,
      onMore: onMore,
      onAmountChanged: onAmountChanged,
      onBaseTap: onBaseTap,
    );
  }
}
