import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/features/convert/models/rate_card_data.dart';
import 'package:currency_converter/src/features/convert/widgets/share/rate_card_image.dart';

void main() {
  const data = RateCardData(
    baseAmountLabel: '100 USD',
    rows: <RateCardRowData>[
      RateCardRowData(name: 'Euro', valueLabel: '€ 86.34'),
      RateCardRowData(name: 'British Pound', valueLabel: '£ 74.57'),
    ],
    footerLabel: 'Updated Jun 15',
  );

  testWidgets('renders wordmark, amount, rows, and footer without overflow',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: RateCardImage(data: data)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Niduna · Currency'), findsOneWidget);
    expect(find.text('100 USD'), findsOneWidget);
    expect(find.text('Euro'), findsOneWidget);
    expect(find.text('€ 86.34'), findsOneWidget);
    expect(find.text('Updated Jun 15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
