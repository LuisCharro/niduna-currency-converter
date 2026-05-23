import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/remove_ads_button.dart';
import 'ad_banner_placeholder.dart';

/// Integrated ad footer instrument (D2-CON-10, M2-1).
class AdSupportShelf extends StatelessWidget {
  const AdSupportShelf({
    required this.onRemoveAds,
    super.key,
  });

  final VoidCallback onRemoveAds;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: .14)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AdBannerPlaceholder(),
          RemoveAdsButton(onPressed: onRemoveAds),
        ],
      ),
    );
  }
}
