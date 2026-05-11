import 'package:flutter/material.dart';

import '../../../core/preferences/app_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../settings_controller.dart';
import '../../../shared/widgets/settings_tile.dart';

class VersionTile extends StatelessWidget {
  const VersionTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final devModeEnabled = controller.preferences.devMode;
    return GestureDetector(
      onLongPress: () => controller.toggleDevMode(context),
      child: SettingsTile(
        title: 'Version',
        trailing: Text(
          '1.0.0${devModeEnabled ? ' · DEV' : ''}',
          style: AppTheme.caption.copyWith(color: AppTheme.muted),
        ),
      ),
    );
  }
}
