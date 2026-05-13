import 'package:flutter/material.dart';

import '../../../shared/widgets/remove_ads_button.dart';
import 'ad_banner_placeholder.dart';

class AdSupportShelf extends StatelessWidget {
  const AdSupportShelf({
    required this.onRemoveAds,
    this.showDivider = false,
    super.key,
  });

  final VoidCallback onRemoveAds;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showDivider) const Divider(height: 1),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AdBannerPlaceholder(),
            RemoveAdsButton(onPressed: onRemoveAds),
          ],
        ),
      ],
    );
  }
}
