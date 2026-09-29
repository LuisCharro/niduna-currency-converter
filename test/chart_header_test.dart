import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/features/charts/widgets/chart_header.dart';
import 'package:currency_converter/src/shared/widgets/screen_title.dart';

void main() {
  Widget host(double width, {double textScale = 1}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 900),
          textScaler: TextScaler.linear(textScale),
        ),
        child: const Scaffold(
          body: ChartHeader(
            base: 'USD',
            quote: 'EUR',
            rate: 0.879450,
            changePercent: 1.42,
            lastUpdated: null,
          ),
        ),
      ),
    );
  }

  testWidgets('renders a single screen-title headline at 360dp', (
    tester,
  ) async {
    await tester.pumpWidget(host(360));
    await tester.pumpAndSettle();
    expect(find.byType(ScreenTitle), findsOneWidget);
    expect(find.textContaining('USD / EUR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at 360dp with text scale 2.0', (
    tester,
  ) async {
    await tester.pumpWidget(host(360, textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
