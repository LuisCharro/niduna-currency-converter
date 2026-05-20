import 'package:flutter/material.dart';

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
        color: AppTheme.container.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            adsEnabled ? Icons.visibility : Icons.visibility_off,
            size: 16,
            color: AppTheme.muted,
          ),
          const SizedBox(width: 8),
          Text(
            adsEnabled ? 'Ads: visible' : 'Ads: hidden',
            style: const TextStyle(fontSize: 13, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}
