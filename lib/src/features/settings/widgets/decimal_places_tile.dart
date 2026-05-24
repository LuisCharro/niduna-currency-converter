import 'package:flutter/material.dart';

import '../../../core/preferences/app_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../settings_controller.dart';
import '../../../shared/widgets/settings_tile.dart';

class DecimalPlacesTile extends StatelessWidget {
  const DecimalPlacesTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return SettingsTile(
      title: loc.labelDecimalPlaces,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppPreferences.supportedDecimalPlaces.map((v) {
          final selected = v == controller.preferences.decimalPlaces;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              onTap: () => controller.setDecimalPlaces(v),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.of(context).primary
                      : AppColors.of(context).container,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? AppColors.of(context).primary
                        : AppColors.of(context).border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$v',
                  style: AppTheme.settingsTileTitleStyle(context).copyWith(
                    color: selected ? Colors.white : AppColors.of(context).text,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
