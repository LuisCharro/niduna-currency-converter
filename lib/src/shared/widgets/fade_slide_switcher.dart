import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class FadeSlideSwitcher extends StatelessWidget {
  const FadeSlideSwitcher({
    required this.child,
    this.duration = AppTheme.motionMedium,
    this.offset = const Offset(0, .03),
    this.switcherKey,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Offset offset;
  final Key? switcherKey;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: switcherKey,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppTheme.curveEnter,
        switchOutCurve: AppTheme.curveExit,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(begin: offset, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: AppTheme.curveEnter),
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: child,
      ),
    );
  }
}
