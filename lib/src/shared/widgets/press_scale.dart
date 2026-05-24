import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PressScale extends StatefulWidget {
  const PressScale({
    required this.child,
    this.onTap,
    this.pressedScale = .985,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: AppTheme.motionFast,
        curve: AppTheme.curveStandard,
        child: widget.child,
      ),
    );
  }
}
