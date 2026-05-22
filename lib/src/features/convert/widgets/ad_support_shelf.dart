import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.container,
        border: Border(
          top: BorderSide(color: AppTheme.instrumentBorder(.14)),
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
