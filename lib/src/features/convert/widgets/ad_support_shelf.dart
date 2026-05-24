import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'ad_banner_placeholder.dart';

/// Integrated ad footer instrument (D2-CON-10, M2-1).
class AdSupportShelf extends StatelessWidget {
  const AdSupportShelf({super.key});

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
        children: <Widget>[const AdBannerPlaceholder()],
      ),
    );
  }
}
