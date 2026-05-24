import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'press_scale.dart';

class FloatingPillNavItem extends StatelessWidget {
  const FloatingPillNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = isSelected ? colors.primary : colors.muted;
    final labelStyle = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w800,
      color: color,
    );
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: PressScale(
          onTap: onTap,
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedScale(
                  scale: isSelected ? 1 : .94,
                  duration: AppTheme.motionMedium,
                  curve: AppTheme.curveStandard,
                  child: Icon(icon, size: 23, color: color),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: AppTheme.motionMedium,
                  curve: AppTheme.curveStandard,
                  style: labelStyle,
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
