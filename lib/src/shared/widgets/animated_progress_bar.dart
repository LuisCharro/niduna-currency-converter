import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AnimatedProgressBar extends StatefulWidget {
  const AnimatedProgressBar({
    required this.duration,
    this.accentColor,
    super.key,
  });

  final Duration duration;
  final Color? accentColor;

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? AppColors.of(context).primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: Colors.white.withValues(alpha: .15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        );
      },
    );
  }
}
