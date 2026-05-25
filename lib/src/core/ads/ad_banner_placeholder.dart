import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({this.maxWidth, super.key});

  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final width = maxWidth == null ? 320.0 : maxWidth!.clamp(280.0, 420.0);
    return Center(
      child: SizedBox(
        width: width,
        height: 50,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: colors.border.withValues(alpha: .12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.ads_click_rounded, color: colors.subtle, size: 15),
              SizedBox(width: AppTheme.space2),
              Flexible(
                child: Text(
                  'Sponsored placement',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.subtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
