import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'floating_pill_active_pill.dart';
import 'floating_pill_nav_item.dart';

class FloatingPillNavBar extends StatelessWidget {
  const FloatingPillNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final List<({IconData icon, String label})> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const inset = 5.0;
        final pillWidth = (constraints.maxWidth - (inset * 2)) / items.length;
        return Container(
          height: AppTheme.floatingNavHeight,
          decoration: BoxDecoration(
            color: colors.container,
            borderRadius: BorderRadius.circular(AppTheme.navOuterRadius),
            border: Border.all(color: colors.border.withValues(alpha: .22)),
            boxShadow: AppTheme.floatingShadowFor(context),
          ),
          child: Stack(
            children: <Widget>[
              FloatingPillActivePill(
                left: inset + (pillWidth * selectedIndex),
                width: pillWidth,
              ),
              Row(children: _navItems()),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _navItems() {
    return List<Widget>.generate(items.length, (index) {
      final item = items[index];
      return FloatingPillNavItem(
        icon: item.icon,
        label: item.label,
        isSelected: selectedIndex == index,
        onTap: () => onTap(index),
      );
    });
  }
}
