import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_header.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_touch_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChartHeader labels the displayed rate in the quote currency', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: ChartHeader(
              base: 'USD',
              quote: 'EUR',
              rate: .86266,
              changePercent: -.41,
              lastUpdated: DateTime(2026, 9, 11),
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 USD = 0.862660 EUR'), findsOneWidget);
    expect(find.text(r'$ 0.862660'), findsNothing);
    expect(find.text('Checked Sep 11'), findsOneWidget);
    expect(find.textContaining('Daily data'), findsNothing);
    expect(tester.getRect(find.text('Checked Sep 11')).right, 340);
    expect(find.byIcon(Icons.swap_vert_rounded), findsNothing);
  });

  testWidgets('ChartHeader aligns the trend beside the rate on wide layouts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 1080,
            child: ChartHeader(
              base: 'USD',
              quote: 'BTC',
              rate: .00001301,
              changePercent: -17.07,
              lastUpdated: DateTime(2026, 9, 11),
            ),
          ),
        ),
      ),
    );

    final rate = tester.getRect(find.text('1 USD = 0.00001301 BTC'));
    final trendChip = find.ancestor(
      of: find.text('↓ 17.07%'),
      matching: find.byType(Container),
    );
    final trend = tester.getRect(trendChip);
    expect(trend.left, greaterThan(rate.right));
    expect(
      trend.right,
      tester.getRect(find.byType(ChartHeader)).right - AppTheme.pageInsets.right,
    );
  });

  testWidgets('ChartTouchOverlay keeps the negative sign on absolute delta', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ChartTouchOverlay(
            date: DateTime(2026, 9, 11),
            currencyCode: 'EUR',
            value: .86266,
            baseValue: .86618,
            lineColor: Colors.red,
          ),
        ),
      ),
    );

    expect(find.text('−0.003520 EUR'), findsOneWidget);
    expect(find.textContaining('2026'), findsOneWidget);
  });
}
