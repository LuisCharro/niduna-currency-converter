import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations_safe.dart';
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
    final loc = l10n(context);
    return Column(
      children: <Widget>[
        SectionHeader(title: loc.labelData),
        SwitchTile(
          title: loc.labelRefreshOnOpen,
          subtitle: loc.labelRefreshOnOpenSubtitle,
          value: controller.preferences.refreshOnOpen,
          onChanged: controller.toggleRefreshOnOpen,
        ),
        SettingsTile(
          title: loc.dataDetailsTitle,
          subtitle: loc.dataSourcesSubtitle,
          onTap: () => controller.openDataDetails(context),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.of(context).subtle,
          ),
        ),
        ClearCacheTile(controller: controller),
      ],
    );
  }
}
