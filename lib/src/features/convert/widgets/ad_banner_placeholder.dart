import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.container.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
      ),
      child: const Column(
        children: <Widget>[
          Text(
            'ADVERTISEMENT PLACEMENT',
            style: TextStyle(
              color: AppTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Premium Financial Services Ad Space',
            style: TextStyle(color: AppTheme.subtle, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
