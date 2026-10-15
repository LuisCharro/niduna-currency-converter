import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The phone shows the destination orientation; the curved arrow indicates rotation.
class ChartOrientationIcon extends StatelessWidget {
  const ChartOrientationIcon({required this.targetLandscape, super.key});
  final bool targetLandscape;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size.square(30),
    painter: _PhoneRotationPainter(
      targetLandscape,
      IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface,
    ),
  );
}

class _PhoneRotationPainter extends CustomPainter {
  const _PhoneRotationPainter(this.landscape, this.color);
  final bool landscape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 30, size.height / 30);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final phone = Rect.fromCenter(
      center: const Offset(15, 15),
      width: landscape ? 17 : 10,
      height: landscape ? 10 : 17,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(phone, const Radius.circular(2)),
      stroke,
    );
    canvas.drawLine(
      landscape ? const Offset(21, 13.5) : const Offset(13.5, 21),
      landscape ? const Offset(21, 16.5) : const Offset(16.5, 21),
      stroke,
    );
    const start = math.pi * .8;
    const end = math.pi * 2.05;
    canvas.drawArc(
      const Rect.fromLTWH(3.5, 3.5, 23, 23),
      start,
      end - start,
      false,
      stroke,
    );
    final tip = Offset(15 + 11.5 * math.cos(end), 15 + 11.5 * math.sin(end));
    final tangent = Offset(-math.sin(end), math.cos(end));
    final normal = Offset(math.cos(end), math.sin(end));
    final base = tip - tangent * 3.2;
    canvas.drawPath(
      Path()
        ..moveTo((base + normal * 2.2).dx, (base + normal * 2.2).dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo((base - normal * 2.2).dx, (base - normal * 2.2).dy),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_PhoneRotationPainter oldDelegate) =>
      oldDelegate.landscape != landscape || oldDelegate.color != color;
}
