import 'package:currency_converter/src/features/charts/widgets/charts_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chart provider failure uses neutral recovery guidance', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartsErrorState(
            message: 'Historical data is unavailable for this pair right now.',
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(
      find.text('Historical data is unavailable right now. Try again later.'),
      findsOneWidget,
    );
    expect(find.text('Check your connection and try again'), findsNothing);
    expect(find.byIcon(Icons.show_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsNothing);
  });
}
