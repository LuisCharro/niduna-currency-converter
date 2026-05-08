import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/app.dart';
import 'package:currency_converter/src/features/convert/convert_screen.dart';
import 'package:currency_converter/src/features/favorites/favorites_screen.dart';
import 'package:currency_converter/src/features/charts/charts_screen.dart';
import 'package:currency_converter/src/features/settings/settings_screen.dart';

void main() {
  testWidgets('app launches with 4 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const CurrencyConverterApp());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Charts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Niduna Convert'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('Convert screen shows Stitch-translated content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ConvertScreen()));
    expect(find.text('LOCAL-ONLY DATA'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('NZD'), findsOneWidget);
    expect(find.text('BTC'), findsNothing);
    expect(find.text('ETH'), findsNothing);
    expect(find.text('ADVERTISEMENT PLACEMENT'), findsOneWidget);
  });

  testWidgets('Favorites screen shows placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FavoritesScreen()));
    expect(find.text('Saved currency pairs'), findsOneWidget);
  });

  testWidgets('Charts screen shows placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChartsScreen()));
    expect(find.text('Historical rate charts'), findsOneWidget);
  });

  testWidgets('Settings screen shows placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    expect(find.text('App settings'), findsOneWidget);
  });
}
