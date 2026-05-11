import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: Material(
          elevation: 4,
          shadowColor: AppTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.container,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.border.withValues(alpha: .3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _PillItem(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Convert',
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _PillItem(
                  icon: Icons.show_chart_rounded,
                  label: 'Chart',
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                _PillItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillItem extends StatelessWidget {
  const _PillItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primary : AppTheme.muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
