import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/purchase_service.dart';
import '../../shared/widgets/bottom_tab_frame.dart';
import '../../shared/widgets/canvas_background.dart';
import '../convert/presentation/convert_controller.dart';
import '../convert/widgets/ad_support_shelf.dart';
import '../settings/widgets/iap_purchase_player.dart';
import 'data/favorites_store.dart';
import 'domain/favorite_pair.dart';
import 'widgets/favorites_rewarded_ad_player.dart';
import 'widgets/favorites_tab_body.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    required this.favoritesStore,
    required this.controller,
    required this.monetization,
    required this.onNavigateToConvert,
    super.key,
  });

  final FavoritesStore favoritesStore;
  final ConvertController controller;
  final MonetizationController monetization;
  final void Function(String base, String quote) onNavigateToConvert;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CanvasBackground(
        child: ListenableBuilder(
          listenable: Listenable.merge([favoritesStore, controller, monetization]),
          builder: (context, _) => BottomTabFrame(
            body: FavoritesTabBody(
              pairs: favoritesStore.pairs,
              effectiveLimit: monetization.favoritesEffectiveLimit,
              visibleLimit: monetization.favoritesVisibleLimit,
              hasFavoritesPro: monetization.hasFavoritesProLifetime,
              canOfferBoost: monetization.canOfferRewardedFavoritesBoost,
              snapshot: controller.snapshot,
              onOpen: _openPair,
              onRemove: controller.removeFavoritePair,
              onAdd: () => onNavigateToConvert('', ''),
              onWatchAd: () => _showRewardedAd(context),
              onBuyPro: () => _purchasePro(context),
            ),
            footer: monetization.adsEnabled ? const AdSupportShelf() : null,
          ),
        ),
      ),
    );
  }

  Future<void> _openPair(FavoritePair pair) async {
    await controller.openFavoritePair(pair);
    onNavigateToConvert(pair.base, pair.quote);
  }

  void _showRewardedAd(BuildContext context) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => FavoritesRewardedAdPlayer(
          controller: monetization,
          onResult: (success) => Navigator.of(context).pop(success),
        ),
      ),
    );
  }

  void _purchasePro(BuildContext context) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => IapPurchasePlayer(
          controller: monetization,
          product: ProductType.favoritesPro,
          onResult: (success) => Navigator.of(context).pop(success),
        ),
      ),
    );
  }
}
