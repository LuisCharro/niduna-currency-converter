import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';
import 'section_header.dart';
import 'version_tile.dart';

class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SectionHeader(title: 'About'),
        SettingsTile(
          title: 'Data sources',
          subtitle: 'Frankfurter, ECB, crypto sources and chart availability',
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
