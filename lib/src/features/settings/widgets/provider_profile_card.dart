import 'package:flutter/material.dart';

import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ProviderProfileCard extends StatelessWidget {
  const ProviderProfileCard({required this.info, super.key});

  final ProviderUsageInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.of(context).container.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Active provider profile',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            info.profileLabel,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            info.isReleaseSafe
                ? 'Store-safe profile. CoinPaprika is not active in release mode.'
                : 'Developer profile. CoinPaprika can be used in dev flows.',
            style: TextStyle(fontSize: 12, color: AppColors.of(context).muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ChipLabel(label: 'PROVIDER_PROFILE=${info.profileValue}'),
              _ChipLabel(label: info.devModeValue),
              _ChipLabel(
                label: info.cryptoChartsEnabled
                    ? 'Crypto charts enabled'
                    : 'Crypto charts disabled',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.of(context).border.withValues(alpha: .4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: AppColors.of(context).muted),
      ),
    );
  }
}
