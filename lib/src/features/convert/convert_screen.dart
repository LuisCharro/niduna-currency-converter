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
              padding: const EdgeInsets.only(bottom: 74),
              child: ListenableBuilder(
                listenable: monetization,
                builder: (context, _) {
                  if (!monetization.adsEnabled) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const AdBannerPlaceholder(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showRemoveAds(context),
                            icon: Icon(Icons.ad_units_outlined, size: 16, color: AppTheme.muted),
                            label: Text(
                              'Remove ads',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.muted),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.pillRadius)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
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
