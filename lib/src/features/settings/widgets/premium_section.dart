import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';
import 'upgrade_shelf.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return Column(
      children: <Widget>[
        UpgradeShelf(controller: controller),
        SettingsTile(
          title: loc.labelSubscription,
          subtitle: loc.labelSubscriptionSubtitle,
          trailing: Text(
            loc.labelSoon,
            style: AppTheme.supportingTextStyle(context).copyWith(
              color: AppColors.of(context).muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SettingsTile(
          title: loc.labelRestorePurchases,
          subtitle: loc.labelRestorePurchasesSubtitle,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.of(context).subtle,
          ),
          showDivider: false,
          onTap: () => controller.restorePurchases(context),
        ),
      ],
    );
  }
}
