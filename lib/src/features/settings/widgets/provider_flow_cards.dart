import 'package:flutter/material.dart';

import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_theme.dart';

class ProviderFlowCards extends StatelessWidget {
  const ProviderFlowCards({required this.roles, super.key});

  final List<ProviderUsageRole> roles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: roles
          .map(
            (role) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProviderFlowCard(role: role),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ProviderFlowCard extends StatelessWidget {
  const _ProviderFlowCard({required this.role});

  final ProviderUsageRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            role.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            role.provider,
            style: const TextStyle(fontSize: 12, color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          for (final detail in role.details) ...<Widget>[
            Text(
              detail,
              style: const TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
