import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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
    final bottom = 20 + MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.container,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppTheme.border.withValues(alpha: .22)),
            boxShadow: AppTheme.floatingShadow,
          ),
          child: Row(
            children: <Widget>[
              FloatingPillNavItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Convert',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              FloatingPillNavItem(
                icon: Icons.show_chart_rounded,
                label: 'Chart',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              FloatingPillNavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
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
