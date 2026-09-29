import 'package:flutter/material.dart';

/// Clamps the inherited text scale for [child] so compact layouts (nav
/// labels, swipe-action tiles, badges, dense rows) stay within their
/// allotted space at large system font sizes instead of overflowing.
///
/// At the platform default scale (1.0) this is a no-op, so normal-scale
/// visuals are unchanged.
class ClampedTextScale extends StatelessWidget {
  const ClampedTextScale({
    required this.child,
    this.maxScaleFactor = 1.3,
    super.key,
  });

  final Widget child;
  final double maxScaleFactor;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxScaleFactor,
      child: child,
    );
  }
}
