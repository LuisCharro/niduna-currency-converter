import 'package:flutter/material.dart';

import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';

/// Divider-integrated premium group (D2-SET-3).
class UpgradeShelf extends StatelessWidget {
  const UpgradeShelf({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final m = controller.monetization;
    final hasPremium =
        m.hasActiveSubscription ||
        m.hasChartsProLifetime ||
        m.hasRemoveAdsLifetime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            2,
            AppTheme.space2,
            2,
            AppTheme.space2,
          ),
          child: Text(
            hasPremium ? loc.premiumActive : loc.premiumUnlocks,
            style: AppTheme.settingsGroupTitleStyle(context),
          ),
        ),
        Text(
          hasPremium ? loc.paidUnlocksStay : loc.oneTimePurchaseNote,
          style: AppTheme.supportingTextStyle(context),
        ),
        const SizedBox(height: AppTheme.space3),
        if (!m.hasRemoveAdsLifetime)
          SettingsTile(
            title: loc.labelRemoveAds,
            subtitle: _removeAdsSubtitle(context),
            trailing: _BuyChip(label: loc.btnBuy),
            onTap: () =>
                controller.purchaseProduct(context, ProductType.removeAds),
          )
        else
          SettingsTile(
            title: 'Remove Ads',
            subtitle: loc.ownedOnDevice,
            trailing: _OwnedBadge(),
          ),
        if (!m.hasChartsProLifetime)
          SettingsTile(
            title: loc.chartsProTitle,
            subtitle: _chartsProSubtitle(context),
            trailing: _BuyChip(label: loc.btnBuy),
            onTap: () =>
                controller.purchaseProduct(context, ProductType.chartsPro),
          )
        else
          SettingsTile(
            title: 'Charts Pro',
            subtitle: loc.ownedOnDevice,
            trailing: _OwnedBadge(),
            showDivider: false,
          ),
      ],
    );
  }

  String _removeAdsSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'de' => '1.99 CHF · dauerhaft auf diesem Gerät',
      'es' => '1.99 CHF · para siempre en este dispositivo',
      'fr' => '1.99 CHF · à vie sur cet appareil',
      'it' => '1.99 CHF · per sempre su questo dispositivo',
      _ => '1.99 CHF · lifetime on this device',
    };
  }

  String _chartsProSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'de' => '2.99 CHF · alle Paare dauerhaft freischalten',
      'es' => '2.99 CHF · desbloquea todos los pares para siempre',
      'fr' => '2.99 CHF · débloque toutes les paires à vie',
      'it' => '2.99 CHF · sblocca tutte le coppie per sempre',
      _ => '2.99 CHF · unlock all pairs forever',
    };
  }
}

class _BuyChip extends StatelessWidget {
  const _BuyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class _OwnedBadge extends StatelessWidget {
  const _OwnedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.of(context).trendUp.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      ),
      child: Text(
        'Owned',
        style: AppTheme.caption.copyWith(
          color: AppColors.of(context).trendUp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
