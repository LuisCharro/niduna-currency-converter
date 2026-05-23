import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';
import 'section_header.dart';
import 'version_tile.dart';

class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return Column(
      children: <Widget>[
        SectionHeader(title: loc.labelAbout),
        SettingsTile(
          title: loc.labelDataSources,
          subtitle: loc.dataSourcesSubtitle,
          onTap: () => controller.openDataSources(context),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.of(context).subtle,
          ),
        ),
        VersionTile(controller: controller),
      ],
    );
  }
}
