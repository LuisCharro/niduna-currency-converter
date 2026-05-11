import 'package:flutter/material.dart';

import '../../../core/preferences/app_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../settings_controller.dart';
import '../../../shared/widgets/settings_tile.dart';

class DecimalPlacesTile extends StatelessWidget {
  const DecimalPlacesTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: 'Decimal places',
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
                  color: selected ? AppTheme.primary : AppTheme.container,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$v',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppTheme.text,
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
