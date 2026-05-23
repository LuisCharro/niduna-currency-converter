import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class DevAdsStatusCard extends StatelessWidget {
  const DevAdsStatusCard({required this.adsEnabled, super.key});

  final bool adsEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.of(context).container.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            adsEnabled ? Icons.visibility : Icons.visibility_off,
            size: 16,
            color: AppColors.of(context).muted,
          ),
          const SizedBox(width: 8),
          Text(
            adsEnabled ? 'Ads: visible' : 'Ads: hidden',
            style: TextStyle(fontSize: 13, color: AppColors.of(context).muted),
          ),
        ],
      ),
    );
  }
}
