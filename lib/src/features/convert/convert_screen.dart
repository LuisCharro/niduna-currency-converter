import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/purchase_service.dart';
import '../../core/theme/app_theme.dart';
import 'presentation/convert_controller.dart';
import 'widgets/ad_banner_placeholder.dart';
import 'widgets/convert_content.dart';
import '../settings/widgets/iap_purchase_player.dart';

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
                  onMore: onNavigateToSettings,
                  maxFavoritesReached: controller.maxFavoritesReached,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 96),
              child: ListenableBuilder(
                listenable: monetization,
                builder: (context, _) {
                  if (!monetization.adsEnabled) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const AdBannerPlaceholder(),
                      TextButton.icon(
                        onPressed: () => _showRemoveAds(context),
                        icon: Icon(
                          Icons.block_rounded,
                          size: 13,
                          color: AppTheme.trendDown,
                        ),
                        label: Text(
                          'Remove ads',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.trendDown,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 28),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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
