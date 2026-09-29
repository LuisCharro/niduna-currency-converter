import 'package:flutter/material.dart';

import '../../../core/preferences/app_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../settings_controller.dart';

/// Compact 3-segment Theme selector (System / Light / Dark). The label is
/// stacked above the segments (rather than sharing a row, as
/// [DecimalPlacesTile] does with its numeric buttons) so long translated
/// labels can wrap instead of overflowing at large text scales.
class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final colors = AppColors.of(context);
    final current = controller.preferences.themeMode;
    final options = <MapEntry<AppThemeMode, String>>[
      MapEntry(AppThemeMode.system, loc.themeModeSystem),
      MapEntry(AppThemeMode.light, loc.themeModeLight),
      MapEntry(AppThemeMode.dark, loc.themeModeDark),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: .14)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 12, 2, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(loc.labelThemeMode, style: AppTheme.settingsTileTitleStyle(context)),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                for (final option in options)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _Segment(
                        label: option.value,
                        selected: option.key == current,
                        onTap: () => controller.setThemeMode(option.key),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? colors.containerHigh : colors.container;
    final unselectedBorder = isDark
        ? colors.border
        : colors.border.withValues(alpha: .35);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? colors.primary : unselectedBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? colors.primary : unselectedBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.supportingTextStyle(context).copyWith(
            color: selected ? Colors.white : colors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
