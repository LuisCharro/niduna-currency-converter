import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class FloatingPillActivePill extends StatelessWidget {
  const FloatingPillActivePill({
    required this.left,
    required this.width,
    super.key,
  });

  final double left;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      key: const Key('nav_active_pill'),
      duration: AppTheme.motionMedium,
      curve: AppTheme.curveStandard,
      left: left,
      top: 5,
      width: width,
      height: AppTheme.floatingNavHeight - 10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.of(context).primary.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(27),
        ),
      ),
    );
  }
}
