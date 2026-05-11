import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_theme.dart';

class DevSandboxSection extends StatelessWidget {
  const DevSandboxSection({required this.monetization, super.key});

  final MonetizationController monetization;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _EntitlementSwitch(
          label: 'Subscription active',
          description: 'Unlocks all premium features and removes ads',
          value: monetization.hasActiveSubscription,
          onChanged: monetization.setSubscriptionActive,
        ),
        const SizedBox(height: 8),
        _EntitlementSwitch(
          label: 'Remove Ads lifetime',
          description: 'Hides ads when no subscription is active',
          value: monetization.hasRemoveAdsLifetime,
          onChanged: monetization.setRemoveAdsLifetime,
        ),
        const SizedBox(height: 8),
        _EntitlementSwitch(
          label: 'Charts Pro lifetime',
          description: 'Unlocks any chart pair without subscription',
          value: monetization.hasChartsProLifetime,
          onChanged: monetization.setChartsProLifetime,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.container.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                monetization.adsEnabled ? Icons.visibility : Icons.visibility_off,
                size: 16,
                color: AppTheme.muted,
              ),
              const SizedBox(width: 8),
              Text(
                monetization.adsEnabled ? 'Ads: visible' : 'Ads: hidden',
                style: TextStyle(fontSize: 13, color: AppTheme.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EntitlementSwitch extends StatelessWidget {
  const _EntitlementSwitch({
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
                Text(label,
                    style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: AppTheme.primary),
        ],
      ),
    );
  }
}
