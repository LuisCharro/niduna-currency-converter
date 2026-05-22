import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';
import 'clear_cache_tile.dart';
import 'section_header.dart';
import 'switch_tile.dart';

class SettingsDataSection extends StatelessWidget {
  const SettingsDataSection({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SectionHeader(title: 'Data'),
        SwitchTile(
          title: 'Refresh on open',
          subtitle: 'Fetch new rates when the app starts',
          value: controller.preferences.refreshOnOpen,
          onChanged: controller.toggleRefreshOnOpen,
        ),
        SettingsTile(
          title: 'Data & sources',
          subtitle: 'ECB daily policy, cache rules, and provider details',
          onTap: () => controller.openDataDetails(context),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.subtle,
          ),
        ),
        ClearCacheTile(controller: controller),
      ],
    );
  }
}
