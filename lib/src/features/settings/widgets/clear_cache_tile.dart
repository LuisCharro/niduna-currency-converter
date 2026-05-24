import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../settings_controller.dart';
import '../../../shared/widgets/settings_tile.dart';

class ClearCacheTile extends StatelessWidget {
  const ClearCacheTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return SettingsTile(
      title: loc.labelClearAllData,
      subtitle: loc.labelClearAllDataSubtitle,
      trailing: InkWell(
        onTap: () => controller.requestClearCache(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.of(context).container,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.of(context).border),
          ),
          child: Text(
            loc.btnClear,
            style: AppTheme.supportingTextStyle(context).copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.of(context).text,
            ),
          ),
        ),
      ),
    );
  }
}
