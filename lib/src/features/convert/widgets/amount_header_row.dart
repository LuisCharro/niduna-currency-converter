import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pill_action.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Niduna',
                style: AppTheme.micro.copyWith(
                  color: AppTheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Convert',
                style: AppTheme.heading.copyWith(
                  fontFamily: 'Fraunces',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PillAction(
          label: 'Rates',
          icon: Icons.tune_rounded,
          onTap: onMore,
        ),
        const SizedBox(width: 8),
        AmountUtilityPill(onRefresh: onRefresh, onMore: onMore),
      ],
    );
  }
}
