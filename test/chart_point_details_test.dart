import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_touch_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [220.0, 560.0]) {
    testWidgets('landscape point retains every value at width $width', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: SizedBox(
                  width: width,
                  height: 100,
                  child: ChartTouchOverlay(
                    date: DateTime(2026, 9, 11),
                    currencyCode: 'EUR',
                    value: .86266,
                    baseValue: .86618,
                    lineColor: Colors.red,
                    compact: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('0.862660 EUR'), findsOneWidget);
      expect(find.text('−0.003520 EUR'), findsOneWidget);
      expect(find.text('↓ 0.41%'), findsOneWidget);
      expect(find.textContaining('2026'), findsOneWidget);
      await tester.ensureVisible(find.text('−0.003520 EUR'));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.text('−0.003520 EUR')).bottom,
        lessThanOrEqualTo(
          tester.getRect(find.byType(ChartTouchOverlay)).bottom,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
