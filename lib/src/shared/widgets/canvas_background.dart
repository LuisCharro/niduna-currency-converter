import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Warm paper canvas with a subtle bottom-weighted gradient (G2-5).
class CanvasBackground extends StatelessWidget {
  const CanvasBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bg,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const <double>[0, 0.65, 1],
          colors: <Color>[
            colors.bg,
            colors.bg.withValues(alpha: .96),
            colors.container,
          ],
        ),
      ),
      child: child,
    );
  }
}
