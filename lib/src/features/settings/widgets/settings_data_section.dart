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
          title: 'Data details',
          subtitle: 'Refresh rules, crypto range limits and cache behavior',
          onTap: () => controller.openDataDetails(context),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.subtle,
          ),
        ),
        ClearCacheTile(controller: controller),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          child: Text(
            'Fiat and crypto data follow a daily app refresh policy.\nOpen Data details for sources, limits, and cache behavior.',
            style: AppTheme.caption.copyWith(color: AppTheme.subtle, height: 1.4),
          ),
        ),
      ],
    );
  }
}
