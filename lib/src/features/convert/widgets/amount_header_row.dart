import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_theme.dart';
import 'amount_utility_pill.dart';

/// Micro rail: CONVERT label + refresh/settings actions (D2-CON-2).
class AmountHeaderRow extends StatelessWidget {
  const AmountHeaderRow({
    required this.onRefresh,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          convertHeaderLabel(context),
          style: AppTheme.sectionLabel.copyWith(
            color: AppTheme.trendUp,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        AmountUtilityPill(onRefresh: onRefresh, onMore: onMore),
      ],
    );
  }
}
