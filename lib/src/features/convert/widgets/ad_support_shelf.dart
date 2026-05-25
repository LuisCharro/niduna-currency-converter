import 'package:flutter/material.dart';

import '../../../core/ads/ad_banner_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Integrated ad footer instrument (D2-CON-10, M2-1).
class AdSupportShelf extends StatelessWidget {
  const AdSupportShelf({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final media = MediaQuery.of(context);
    final navInset =
        media.padding.bottom +
        AppTheme.floatingNavHeight +
        AppTheme.floatingNavBottomOffset +
        AppTheme.bottomDockGap;
    final compact = media.size.height < 760;
    final topPadding = compact ? 4.0 : 8.0;
    final bottomPadding = navInset + (compact ? 4.0 : 8.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: .14)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, topPadding, 20, bottomPadding),
        child: const Align(
          alignment: Alignment.topCenter,
          child: AdBannerWidget(),
        ),
      ),
    );
  }
}
