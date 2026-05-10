import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.monetization,
    super.key,
  });

  final MonetizationController monetization;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: monetization,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: <Widget>[
              Text(
                'Monetization sandbox',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use toggles below to test entitlement behavior in Charts and ad visibility.',
                style: TextStyle(fontSize: 13, color: AppTheme.muted),
              ),
              const SizedBox(height: 16),
              _EntitlementSwitchTile(
                label: 'Subscription active',
                description: 'Unlocks all premium features and removes ads',
                value: monetization.hasActiveSubscription,
                onChanged: monetization.setSubscriptionActive,
              ),
              const SizedBox(height: 10),
              _EntitlementSwitchTile(
                label: 'Remove Ads lifetime',
                description: 'Hides ads when no subscription is active',
                value: monetization.hasRemoveAdsLifetime,
                onChanged: monetization.setRemoveAdsLifetime,
              ),
              const SizedBox(height: 10),
              _EntitlementSwitchTile(
                label: 'Charts Pro lifetime',
                description: 'Unlocks any chart pair without subscription',
                value: monetization.hasChartsProLifetime,
                onChanged: monetization.setChartsProLifetime,
              ),
              const SizedBox(height: 18),
              Text(
                monetization.adsEnabled ? 'Ads: visible' : 'Ads: hidden',
                style: TextStyle(fontSize: 14, color: AppTheme.muted),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EntitlementSwitchTile extends StatelessWidget {
  const _EntitlementSwitchTile({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
