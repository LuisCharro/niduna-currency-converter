import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/app.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/convert_screen.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:currency_converter/src/features/favorites/favorites_screen.dart';
import 'package:currency_converter/src/features/settings/settings_screen.dart';

void main() {
  final repository = _FakeRatesRepository(
    fresh: _snapshot(<String, double>{
      'CHF': .88,
      'EUR': .92,
      'GBP': .79,
      'JPY': 150.23,
      'NZD': 1.64,
    }),
  );

  late SharedPreferences prefs;
  late FavoritesStore favoritesStore;
  late ConvertController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    favoritesStore = FavoritesStore(prefs);
    controller = ConvertController(
      repository: repository,
      favoritesStore: favoritesStore,
    );
    await controller.load();
  });

  tearDown(() {
    favoritesStore.dispose();
    controller.dispose();
  });

  testWidgets('app launches with 4 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      CurrencyConverterApp(
        convertRepository: repository,
        favoritesStore: favoritesStore,
      ),
    );
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
    await tester.pumpWidget(
      MaterialApp(home: ConvertScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('LOCAL-ONLY DATA'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('Fresh rates · 4 shown'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('NZD'), findsNothing);
    expect(find.text('BTC'), findsNothing);
    expect(find.text('ETH'), findsNothing);
    expect(find.text('ADVERTISEMENT PLACEMENT'), findsOneWidget);
  });

  testWidgets('Convert row tap reveals Set as base action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ConvertScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('CHF').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Set CHF as base'), findsOneWidget);

    await tester.tap(find.byTooltip('Set CHF as base'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Set CHF as base'), findsNothing);
    expect(find.text('CHF'), findsWidgets);
  });

  testWidgets('Favorites screen shows placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: FavoritesScreen(
        favoritesStore: favoritesStore,
        controller: controller,
        onNavigateToConvert: (a, b) {},
      ),
    ));
    expect(find.text('No favorite pairs yet'), findsOneWidget);
  });

  testWidgets('Favorites screen shows pair with rate', (
    WidgetTester tester,
  ) async {
    await favoritesStore.add('USD', 'EUR');
    await tester.pumpWidget(MaterialApp(
      home: FavoritesScreen(
        favoritesStore: favoritesStore,
        controller: controller,
        onNavigateToConvert: (a, b) {},
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('USD → EUR'), findsOneWidget);
    expect(find.text('0.9200'), findsOneWidget);
  });

  testWidgets('Settings screen shows placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    expect(find.text('App settings'), findsOneWidget);
  });
}

LatestRatesSnapshot _snapshot(Map<String, double> rates) {
  return LatestRatesSnapshot(
    base: 'USD',
    date: DateTime(2026, 5, 8),
    savedAt: DateTime(2026, 5, 8, 9),
    rates: rates,
  );
}

class _FakeRatesRepository implements ConvertRatesRepository {
  _FakeRatesRepository({required this.fresh});

  final LatestRatesSnapshot? fresh;

  @override
  Future<LatestRatesSnapshot?> readCached(String base) async => null;

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async {
    if (fresh == null) {
      throw StateError('offline');
    }
    return fresh!;
  }
}
