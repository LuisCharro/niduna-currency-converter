import 'dart:math' as math;

import 'package:flutter/material.dart';

class LensPosition {
  const LensPosition({
    required this.width,
    required this.height,
    required this.alignment,
  });

  final double width;
  final double height;
  final Alignment alignment;
}

LensPosition calculateLensPosition(
  Size screenSize,
  EdgeInsets safePadding,
  Offset anchor,
) {
  const hMargin = 20.0;
  const topMargin = 20.0;
  const bottomMargin = 52.0;
  final width = math.min(screenSize.width - hMargin * 2, 380.0);
  final safeHeight = screenSize.height - safePadding.top - safePadding.bottom;
  final availableHeight = math.max(
    320.0,
    safeHeight - topMargin - bottomMargin,
  );
  final height = math.min(
    availableHeight,
    math.min(560.0, math.max(360.0, availableHeight * .74)),
  );
  final left = (screenSize.width - width) / 2;
  final top = screenSize.height - safePadding.bottom - bottomMargin - height;
  final alignment = Alignment(
    ((anchor.dx - left) / width).clamp(0.1, 0.9) * 2 - 1,
    ((anchor.dy - top) / height).clamp(0.1, 0.9) * 2 - 1,
  );
  return LensPosition(width: width, height: height, alignment: alignment);
}
