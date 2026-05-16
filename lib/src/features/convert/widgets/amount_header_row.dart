import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_utility_pill.dart';

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
        Expanded(
          child: Text(
            'Convert',
            style: AppTheme.heading.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        AmountUtilityPill(onRefresh: onRefresh, onMore: onMore),
      ],
    );
  }
}
