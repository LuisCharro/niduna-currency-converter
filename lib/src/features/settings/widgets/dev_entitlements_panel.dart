import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class DevEntitlementsPanel extends StatelessWidget {
  const DevEntitlementsPanel({required this.monetization, super.key});

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
        color: AppColors.of(context).card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: AppColors.of(context).muted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.of(context).primary,
          ),
        ],
      ),
    );
  }
}
