import 'package:flutter/material.dart';

import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pill_action.dart';
import '../settings_controller.dart';

class UpgradeShelf extends StatelessWidget {
  const UpgradeShelf({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final hasPremium = controller.monetization.hasActiveSubscription ||
        controller.monetization.hasChartsProLifetime ||
        controller.monetization.hasRemoveAdsLifetime;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.container.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Premium',
            style: AppTheme.heading.copyWith(
              fontFamily: 'Fraunces',
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasPremium
                ? 'Paid unlocks stay active on this device.'
                : 'One-time unlocks only — no account required.',
            style: AppTheme.caption.copyWith(color: AppTheme.muted, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (!controller.monetization.hasRemoveAdsLifetime)
                PillAction(
                  label: 'Remove Ads · 1.99 CHF',
                  onTap: () =>
                      controller.purchaseProduct(context, ProductType.removeAds),
                  emphasized: true,
                ),
              if (!controller.monetization.hasChartsProLifetime)
                PillAction(
                  label: 'Charts Pro · 2.99 CHF',
                  onTap: () =>
                      controller.purchaseProduct(context, ProductType.chartsPro),
                  emphasized: true,
                ),
              if (controller.monetization.hasRemoveAdsLifetime)
                _OwnedPill(label: 'Remove Ads owned'),
              if (controller.monetization.hasChartsProLifetime)
                _OwnedPill(label: 'Charts Pro owned'),
            ],
          ),
        ],
      ),
    );
  }
}

class _OwnedPill extends StatelessWidget {
  const _OwnedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.trendUp.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
