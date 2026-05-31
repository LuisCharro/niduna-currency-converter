import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ChartTempBadge extends StatelessWidget {
  const ChartTempBadge({required this.compact, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.of(context).primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.of(context).primary.withValues(alpha: .25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: compact ? 9 : 10,
            color: AppColors.of(context).primary,
          ),
          const SizedBox(width: 2),
          Text(
            '24h',
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: AppColors.of(context).primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
