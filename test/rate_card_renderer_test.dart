import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/share/rate_card_renderer.dart';

void main() {
  testWidgets('captureBoundary returns PNG bytes for a mounted boundary',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: ColoredBox(color: Color(0xFF112233)),
            ),
          ),
        ),
      ),
    );

    Uint8List? bytes;
    await tester.runAsync(() async {
      bytes = await RateCardRenderer.captureBoundary(key, pixelRatio: 1);
    });

    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(8));
    // PNG signature.
    expect(
      bytes!.sublist(0, 8),
      equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    );
  });

  testWidgets('returns null when the key has no boundary', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(const SizedBox());
    expect(await RateCardRenderer.captureBoundary(key), isNull);
  });
}
