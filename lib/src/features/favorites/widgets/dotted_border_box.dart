import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A rounded box with a dashed border, drawn with [CustomPaint] since Flutter
/// has no built-in dashed [Border]. Used by the empty slot row and the empty
/// state's "first pair" preview slot.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return CustomPaint(
      painter: _DashedRRectPainter(color: colors.border.withValues(alpha: .35)),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const dashWidth = 6.0;
    const gapWidth = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
