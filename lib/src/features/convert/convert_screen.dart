import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/purchase_service.dart';
import '../../shared/widgets/bottom_tab_frame.dart';
import '../../shared/widgets/canvas_background.dart';
import '../settings/widgets/iap_purchase_player.dart';
import 'presentation/convert_controller.dart';
import 'widgets/ad_support_shelf.dart';
import 'widgets/convert_content.dart';

class ConvertScreen extends StatelessWidget {
  const ConvertScreen({
    required this.controller,
    required this.monetization,
    required this.onNavigateToSettings,
    super.key,
  });

  final ConvertController controller;
  final MonetizationController monetization;
  final VoidCallback onNavigateToSettings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CanvasBackground(
        child: ListenableBuilder(
        listenable: monetization,
        builder: (context, _) => BottomTabFrame(
          body: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => ConvertContent(
              state: controller.state,
              onRefresh: controller.refresh,
              onAmountChanged: controller.setAmountText,
              onSelectBase: controller.setBase,
              onToggleCode: controller.toggleCode,
              onToggleFavorite: controller.toggleFavorite,
              onMore: onNavigateToSettings,
              maxFavoritesReached: controller.maxFavoritesReached,
            ),
          ),
          footer: monetization.adsEnabled
              ? AdSupportShelf(onRemoveAds: () => _showRemoveAds(context))
              : null,
        ),
        ),
      ),
    );
  }

  void _showRemoveAds(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => IapPurchasePlayer(
          controller: monetization,
          product: ProductType.removeAds,
          onResult: (success) => Navigator.of(context).pop(success),
        ),
      ),
    );
  }
}
