import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_line_plot.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'ChartLinePlot includes years when its visible range crosses one',
    (tester) async {
      final dates = <DateTime>[
        DateTime(2025, 12, 30),
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 3),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 280,
              child: ChartLinePlot(
                spots: const [FlSpot(0, .8), FlSpot(1, .85), FlSpot(2, .9)],
                dates: dates,
                minY: .75,
                maxY: .95,
                lineColor: Colors.green,
                touchedIndex: null,
                touchSpotThreshold: 22,
                onTouch: (_, _) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('30 Dec 2025'), findsOneWidget);
      expect(find.text('1 Jan 2026'), findsOneWidget);
      expect(find.text('0.75'), findsNothing);
      expect(find.text('0.95'), findsNothing);
      expect(find.text('EUR'), findsNothing);
    },
  );
}
