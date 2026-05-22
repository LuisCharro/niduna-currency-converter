import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Warm paper canvas with a subtle bottom-weighted gradient (G2-5).
class CanvasBackground extends StatelessWidget {
  const CanvasBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: <double>[0, 0.65, 1],
          colors: <Color>[
            AppTheme.bg,
            Color(0xFFFAFBF4),
            Color(0xFFFFF9EC),
          ],
        ),
      ),
      child: child,
    );
  }
}
