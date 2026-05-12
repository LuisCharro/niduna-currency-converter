import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/app.dart';
import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/rewarded_ad_service_stub.dart';
import 'package:currency_converter/src/core/preferences/app_preferences.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:currency_converter/src/features/favorites/favorites_screen.dart';
import 'package:currency_converter/src/features/convert/convert_screen.dart';
import 'package:currency_converter/src/features/settings/settings_screen.dart';
import 'package:currency_converter/src/shared/widgets/floating_pill_nav.dart';

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
  late MonetizationController monetization;
  late AppPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    favoritesStore = FavoritesStore(prefs);
    preferences = AppPreferences(prefs);
    controller = ConvertController(
      repository: repository,
      favoritesStore: favoritesStore,
    );
    final adService = RewardedAdServiceStub();
    monetization = MonetizationController(prefs, adService: adService);
    await controller.load();
  });

  tearDown(() {
    favoritesStore.dispose();
    controller.dispose();
  });

  testWidgets('app launches with floating pill nav', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CurrencyConverterApp(
        convertRepository: repository,
        favoritesStore: favoritesStore,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingPillNav), findsOneWidget);
    expect(find.text('Convert'), findsWidgets);
    expect(find.text('Chart'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Private daily rates · no tracking'), findsOneWidget);
    expect(find.text('Edit list'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('Convert screen shows clean layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConvertScreen(
          controller: controller,
          monetization: monetization,
          onNavigateToSettings: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('4 shown currencies'), findsOneWidget);
    expect(find.text('Edit list'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('CHF'), findsWidgets);
    expect(find.text('NZD'), findsNothing);
    expect(find.text('BTC'), findsNothing);
    expect(find.text('ETH'), findsNothing);
  });

  testWidgets('Convert currency picker opens on a compact viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ConvertScreen(
          controller: controller,
          monetization: monetization,
          onNavigateToSettings: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit list'));
    await tester.pumpAndSettle();

    expect(find.text('Visible currencies'), findsOneWidget);
    expect(find.text('4 shown · USD base'), findsOneWidget);
    expect(find.text('USD · base currency'), findsOneWidget);
    expect(find.text('CHF · shown now'), findsOneWidget);
    expect(find.text('Currency, country, or code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Convert row tap highlights active row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConvertScreen(
          controller: controller,
          monetization: monetization,
          onNavigateToSettings: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chfFinder = find.text('Swiss Franc');
    expect(chfFinder, findsWidgets);

    await tester.tap(chfFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('Swiss Franc'), findsWidgets);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsWidgets);
  });

  testWidgets('Favorites screen shows placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FavoritesScreen(
          favoritesStore: favoritesStore,
          controller: controller,
          onNavigateToConvert: (a, b) {},
        ),
      ),
    );
    expect(find.text('No favorite pairs yet'), findsOneWidget);
  });

  testWidgets('Favorites screen shows pair with rate', (
    WidgetTester tester,
  ) async {
    await favoritesStore.add('USD', 'EUR');
    await tester.pumpWidget(
      MaterialApp(
        home: FavoritesScreen(
          favoritesStore: favoritesStore,
          controller: controller,
          onNavigateToConvert: (a, b) {},
        ),
      ),
    );
    expect(find.text('USD → EUR'), findsOneWidget);
    expect(find.text('0.9200'), findsOneWidget);
  });

  testWidgets('Settings screen shows sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          monetization: monetization,
          preferences: preferences,
          onClearCache: () {},
        ),
      ),
    );
    expect(find.text('Conversion'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Default base currency'), findsWidgets);
    expect(find.text('Dark mode'), findsWidgets);
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
