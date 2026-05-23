import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'floating_pill_nav_item.dart';

class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom =
        AppTheme.floatingNavBottomOffset + MediaQuery.paddingOf(context).bottom;
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          height: AppTheme.floatingNavHeight,
          decoration: BoxDecoration(
            color: colors.container,
            borderRadius: BorderRadius.circular(AppTheme.navOuterRadius),
            border: Border.all(color: colors.border.withValues(alpha: .22)),
            boxShadow: AppTheme.floatingShadowFor(context),
          ),
          child: Row(
            children: <Widget>[
              FloatingPillNavItem(
                icon: Icons.swap_horiz_rounded,
                label: l10n?.tabConvert ?? "Convert",
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              FloatingPillNavItem(
                icon: Icons.show_chart_rounded,
                label: l10n?.tabCharts ?? "Chart",
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              FloatingPillNavItem(
                icon: Icons.settings_rounded,
                label: l10n?.tabSettings ?? "Settings",
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
