import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';
import 'upgrade_shelf.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        UpgradeShelf(controller: controller),
        const SizedBox(height: 14),
        SettingsTile(
          title: 'Subscription',
          subtitle: 'Not available in v1 · 1 week free trial planned later',
          trailing: Text(
            'Soon',
            style: AppTheme.caption.copyWith(
              color: AppTheme.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SettingsTile(
          title: 'Restore purchases',
          subtitle: 'Re-check local store purchases on this device',
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.subtle,
          ),
          showDivider: false,
          onTap: () => controller.restorePurchases(context),
        ),
      ],
    );
  }
}
