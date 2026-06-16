import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/settings_tile.dart';

class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = subtitle != null ? '$title, $subtitle' : title;
    return Semantics(
      label: label,
      toggled: value,
      onTap: () => onChanged(!value),
      child: ExcludeSemantics(
        child: SettingsTile(
          title: title,
          subtitle: subtitle,
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
