import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../settings_controller.dart';
import 'rate_app_tile.dart';
import 'section_header.dart';
import 'send_feedback_tile.dart';
import 'version_tile.dart';

class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(title: loc.labelAbout),
        RateAppTile(controller: controller),
        SendFeedbackTile(controller: controller),
        VersionTile(controller: controller),
      ],
    );
  }
}
