import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';

/// Opens the app's Google Play listing so users can rate or review it.
class RateAppTile extends StatelessWidget {
  const RateAppTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return SettingsTile(
      key: const Key('rate_app'),
      title: loc.labelRateApp,
      subtitle: loc.rateAppSubtitle,
      onTap: controller.rateApp,
      trailing: Icon(
        Icons.star_outline_rounded,
        color: AppColors.of(context).subtle,
      ),
    );
  }
}
