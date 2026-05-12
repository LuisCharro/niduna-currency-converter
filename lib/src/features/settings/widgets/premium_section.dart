import 'package:flutter/material.dart';

import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../settings_controller.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SubscriptionCard(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: <Widget>[
              Expanded(child: Divider(color: AppTheme.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'or buy separately',
                  style: AppTheme.micro.copyWith(color: AppTheme.subtle),
                ),
              ),
              Expanded(child: Divider(color: AppTheme.border)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _PremiumCard(
          icon: Icons.visibility_off,
          title: 'Remove Ads',
          description: 'Enjoy the app without any advertisements',
          price: '1.99 CHF',
          owned: controller.monetization.hasRemoveAdsLifetime,
          onBuy: () =>
              controller.purchaseProduct(context, ProductType.removeAds),
        ),
        const SizedBox(height: 10),
        _PremiumCard(
          icon: Icons.diamond_outlined,
          title: 'Unlock All Pairs',
          description: 'Select any currency pair in Charts — forever',
          price: '2.99 CHF',
          owned: controller.monetization.hasChartsProLifetime,
          onBuy: () =>
              controller.purchaseProduct(context, ProductType.chartsPro),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => controller.restorePurchases(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
    required this.owned,
    required this.onBuy,
  });

  final IconData icon;
  final String title;
  final String description;
  final String price;
  final bool owned;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 22,
            color: owned ? AppTheme.trendUp : AppTheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!owned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'in Subscription',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          if (owned)
            Icon(Icons.check_circle, size: 20, color: AppTheme.trendUp)
          else ...[
            GestureDetector(
              onTap: onBuy,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.primary.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.workspace_premium_outlined,
                size: 22,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Premium Subscription',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.container.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'All features included',
            style: TextStyle(fontSize: 13, color: AppTheme.text),
          ),
          const SizedBox(height: 6),
          _SubFeatureRow(Icons.visibility_off, 'Remove ads'),
          _SubFeatureRow(Icons.diamond_outlined, 'Unlock all chart pairs'),
          _SubFeatureRow(Icons.show_chart, 'Intraday ranges (1H/6H/1D)'),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Icon(Icons.construction, size: 12, color: AppTheme.muted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '1 week free trial, then X.XX CHF/year',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubFeatureRow extends StatelessWidget {
  const _SubFeatureRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 14, color: AppTheme.muted),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
        ],
      ),
    );
  }
}
