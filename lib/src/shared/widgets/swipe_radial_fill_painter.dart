import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Radial "charge" fill painted under a [SwipeDraggableCard] while a
/// long-press is building toward opening its swipe actions.
class SwipeRadialFillPainter extends CustomPainter {
  const SwipeRadialFillPainter({required this.progress, required this.center});

  final double progress;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final r =
        math.sqrt(size.width * size.width + size.height * size.height) * 0.6;
    final ep = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final op = Curves.easeIn.transform(progress.clamp(0.0, 1.0));
    canvas.drawCircle(
      center,
      r * ep,
      Paint()..color = Color.fromRGBO(45, 106, 70, op * .15),
    );
  }

  @override
  bool shouldRepaint(SwipeRadialFillPainter old) =>
      progress != old.progress || center != old.center;
}
