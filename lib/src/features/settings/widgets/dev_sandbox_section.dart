import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/rates/provider_config.dart';
import '../../../core/theme/app_theme.dart';

class DevSandboxSection extends StatelessWidget {
  const DevSandboxSection({required this.monetization, super.key});

  final MonetizationController monetization;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.container.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Provider profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ProviderConfig.profileLabel,
                style: const TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
              const SizedBox(height: 10),
              const Text(
                'All providers',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              _ProviderTable(providers: ProviderConfig.allProviders),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
            border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
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
                style: const TextStyle(fontSize: 13, color: AppTheme.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProviderTable extends StatelessWidget {
  const _ProviderTable({required this.providers});

  final List<ProviderInfo> providers;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: IntrinsicColumnWidth(),
      },
      children: <TableRow>[
        const TableRow(
          children: <Widget>[
            Text('Provider', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.muted)),
            Text('Type', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.muted)),
            Text('Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.muted)),
          ],
        ),
        ...providers.map((p) => TableRow(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(p.name, style: const TextStyle(fontSize: 11)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(p.type, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Icon(
                p.active ? Icons.check_circle : Icons.cancel_outlined,
                size: 14,
                color: p.active ? Colors.green : AppTheme.muted,
              ),
            ),
          ],
        )),
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
        color: AppTheme.containerHigh.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .14)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}