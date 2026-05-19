import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../settings_controller.dart';
import '../../../shared/widgets/settings_tile.dart';

class ClearCacheTile extends StatelessWidget {
  const ClearCacheTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: 'Clear all data',
      subtitle: 'Fiat rates, crypto rates, chart history and temporary unlocks',
      trailing: InkWell(
        onTap: () => controller.requestClearCache(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.container,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            'Clear',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
        ),
      ),
    );
  }
}
