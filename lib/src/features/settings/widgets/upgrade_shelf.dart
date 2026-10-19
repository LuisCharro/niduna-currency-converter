import 'package:flutter/material.dart';

import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';
import 'store_prices_builder.dart';
import 'upgrade_product_copy.dart';

/// Divider-integrated premium group (D2-SET-3).
class UpgradeShelf extends StatelessWidget {
  const UpgradeShelf({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final monetization = controller.monetization;
    final hasPremium =
        monetization.hasActiveSubscription ||
        monetization.hasChartsProLifetime ||
        monetization.hasRemoveAdsLifetime ||
        monetization.hasFavoritesProLifetime;

    return StorePricesBuilder(
      controller: monetization,
      builder: (context, prices) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, AppTheme.space2),
            child: Text(
              hasPremium
                  ? l10n(context).paidUnlocksStay
                  : l10n(context).oneTimePurchaseNote,
              style: AppTheme.supportingTextStyle(context),
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          _productTile(
            context,
            prices,
            product: ProductType.removeAds,
            title: l10n(context).labelRemoveAds,
            owned: monetization.hasRemoveAdsLifetime,
            onTap: () =>
                controller.purchaseProduct(context, ProductType.removeAds),
          ),
          _productTile(
            context,
            prices,
            product: ProductType.chartsPro,
            title: l10n(context).chartsProTitle,
            owned: monetization.hasChartsProLifetime,
            onTap: () =>
                controller.purchaseProduct(context, ProductType.chartsPro),
          ),
          _productTile(
            context,
            prices,
            product: ProductType.favoritesPro,
            title: l10n(context).favoritesProTitle,
            owned: monetization.hasFavoritesProLifetime,
            onTap: () =>
                controller.purchaseProduct(context, ProductType.favoritesPro),
            showDivider: !monetization.hasFavoritesProLifetime,
          ),
        ],
      ),
    );
  }

  Widget _productTile(
    BuildContext context,
    Map<ProductType, String> prices, {
    required ProductType product,
    required String title,
    required bool owned,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    if (owned) {
      return SettingsTile(
        title: title,
        subtitle: l10n(context).ownedOnDevice,
        trailing: _OwnedBadge(label: l10n(context).ownedOnDevice),
        showDivider: showDivider,
      );
    }

    final description = upgradeProductDescription(context, product);
    final price = prices[product];
    return SettingsTile(
      title: title,
      subtitle: price == null || price.trim().isEmpty
          ? description
          : '$price · $description',
      trailing: _BuyChip(label: l10n(context).btnBuy),
      onTap: onTap,
      showDivider: showDivider,
    );
  }
}

class _BuyChip extends StatelessWidget {
  const _BuyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.of(context).primary,
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
    ),
    child: Text(
      label,
      style: AppTheme.caption.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _OwnedBadge extends StatelessWidget {
  const _OwnedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.of(context).trendUp.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
    ),
    child: Text(
      label,
      style: AppTheme.caption.copyWith(
        color: AppColors.of(context).trendUp,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
