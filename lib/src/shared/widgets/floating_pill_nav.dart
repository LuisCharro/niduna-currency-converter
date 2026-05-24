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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const itemCount = 3;
              const inset = 5.0;
              final pillWidth =
                  (constraints.maxWidth - (inset * 2)) / itemCount;
              final pillLeft = inset + (pillWidth * selectedIndex);
              return Container(
                height: AppTheme.floatingNavHeight,
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppTheme.navOuterRadius),
                  border: Border.all(
                    color: colors.border.withValues(alpha: .22),
                  ),
                  boxShadow: AppTheme.floatingShadowFor(context),
                ),
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      key: const Key('nav_active_pill'),
                      duration: AppTheme.motionMedium,
                      curve: AppTheme.curveStandard,
                      left: pillLeft,
                      top: inset,
                      width: pillWidth,
                      height: AppTheme.floatingNavHeight - (inset * 2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                    ),
                    Row(
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
