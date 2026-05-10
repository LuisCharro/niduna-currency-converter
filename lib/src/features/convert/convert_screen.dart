import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/theme/app_theme.dart';
import 'presentation/convert_controller.dart';
import 'widgets/ad_banner_placeholder.dart';
import 'widgets/convert_content.dart';

class ConvertScreen extends StatelessWidget {
  const ConvertScreen({
    required this.controller,
    required this.monetization,
    super.key,
  });

  final ConvertController controller;
  final MonetizationController monetization;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bg,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => ConvertContent(
                  state: controller.state,
                  onRefresh: controller.refresh,
                  onAmountChanged: controller.setAmountText,
                  onSelectBase: controller.setBase,
                  onToggleCode: controller.toggleCode,
                  onToggleFavorite: controller.toggleFavorite,
                  maxFavoritesReached: controller.maxFavoritesReached,
                ),
              ),
            ),
            ListenableBuilder(
              listenable: monetization,
              builder: (context, _) {
                if (!monetization.adsEnabled) {
                  return const SizedBox.shrink();
                }
                return const AdBannerPlaceholder();
              },
            ),
          ],
        ),
      ),
    );
  }
}
