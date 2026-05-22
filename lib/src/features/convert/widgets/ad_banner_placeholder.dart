import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.fromLTRB(
        AppTheme.space5,
        AppTheme.space2,
        AppTheme.space5,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.instrumentBorder(.12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.ads_click_rounded, color: AppTheme.subtle, size: 15),
          SizedBox(width: AppTheme.space2),
          Flexible(
            child: Text(
              'Sponsored placement',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.subtle,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
