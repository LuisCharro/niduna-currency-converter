import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Captures a mounted RepaintBoundary (referenced by [key]) to PNG bytes.
/// Separated from the share orchestration so it can be unit-tested.
class RateCardRenderer {
  static Future<Uint8List?> captureBoundary(
    GlobalKey key, {
    double pixelRatio = 3,
  }) async {
    final object = key.currentContext?.findRenderObject();
    if (object is! RenderRepaintBoundary) return null;
    final ui.Image image = await object.toImage(pixelRatio: pixelRatio);
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }
}
