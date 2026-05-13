import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class RemoveAdsButton extends StatelessWidget {
  const RemoveAdsButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.ad_units_outlined,
            size: 16,
            color: AppTheme.trendDown,
          ),
          label: Text(
            'Remove ads',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.trendDown,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.trendDown.withValues(alpha: .4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            backgroundColor: AppTheme.trendDown.withValues(alpha: .06),
          ),
        ),
      ),
    );
  }
}
