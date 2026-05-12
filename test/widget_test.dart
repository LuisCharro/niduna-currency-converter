import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/app.dart';
import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/rewarded_ad_service_stub.dart';
import 'package:currency_converter/src/core/preferences/app_preferences.dart';
import 'package:currency_converter/src/core/rates/models/rates_snapshot.dart';
import 'package:currency_converter/src/core/rates/rates_cache.dart';
import 'package:currency_converter/src/core/rates/rates_client.dart';
import 'package:currency_converter/src/core/rates/rates_service.dart';
import 'package:currency_converter/src/features/charts/charts_screen.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/charts/presentation/charts_controller.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:currency_converter/src/features/favorites/favorites_screen.dart';
import 'package:currency_converter/src/features/convert/convert_screen.dart';
import 'package:currency_converter/src/features/charts/widgets/rate_chart.dart';
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
    expect(find.textContaining('Updated'), findsOneWidget);
    expect(find.text('Add currencies'), findsOneWidget);
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

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('4 shown currencies'), findsOneWidget);
    expect(find.text('Add currencies'), findsOneWidget);
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

    await tester.tap(find.text('Add currencies'));
    await tester.pumpAndSettle();

    expect(find.text('Visible currencies'), findsOneWidget);
    expect(find.text('4 shown · USD base'), findsOneWidget);
    expect(find.text('USD · base currency'), findsOneWidget);
    expect(find.text('CHF · shown now'), findsOneWidget);
    expect(find.text('Currency, country, or code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Convert row tap selects, then second tap sets base', (
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
    expect(find.text('Set as base'), findsOneWidget);
    expect(find.text('1 USD = 0.88 CHF'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsNothing);
    expect(controller.state.base, 'USD');

    await tester.tap(chfFinder.first);
    await tester.pumpAndSettle();

    expect(controller.state.base, 'CHF');
    expect(find.text('Set as base'), findsNothing);
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

  testWidgets('Rate chart uses a stronger touched indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 320,
            child: RateChart(
              data: <DateTime, double>{
                DateTime(2026, 5, 10): 0.8519,
                DateTime(2026, 5, 11): 0.8542,
                DateTime(2026, 5, 12): 0.8497,
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    final data = chart.data;
    final indicators = data.lineTouchData.getTouchedSpotIndicator(
      data.lineBarsData.first,
      <int>[1],
    );
    final indicator = indicators.single;

    expect(indicator, isNotNull);
    expect(
      indicator!.indicatorBelowLine.strokeWidth,
      greaterThanOrEqualTo(2.0),
    );
  });

  testWidgets('Charts screen keeps helper text above nav when ads are hidden', (
    WidgetTester tester,
  ) async {
    await monetization.setRemoveAdsLifetime(true);
    final chartsController = ChartsController(
      ratesService: RatesService(
        client: _FakeRatesClient(),
        cache: _FakeRatesCache(),
      ),
    );
    addTearDown(chartsController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ChartsScreen(
          controller: chartsController,
          monetization: monetization,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final helperText = find.text('Tap currencies above to explore other pairs');
    expect(helperText, findsOneWidget);

    final helperPadding = tester.widget<Padding>(
      find.ancestor(of: helperText, matching: find.byType(Padding)).first,
    );
    expect(
      helperPadding.padding.resolve(TextDirection.ltr).bottom,
      greaterThanOrEqualTo(120),
    );
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

class _FakeRatesClient implements RatesClient {
  @override
  Future<RatesSnapshot> fetchLatest(String base) async {
    throw UnimplementedError();
  }

  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    return HistoricalSnapshot(
      base: base,
      quote: quote,
      coveredFrom: from,
      coveredTo: to,
      savedAt: DateTime(2026, 5, 12, 9),
      data: <DateTime, double>{
        DateTime(2026, 5, 10): 0.8519,
        DateTime(2026, 5, 11): 0.8542,
        DateTime(2026, 5, 12): 0.8497,
      },
    );
  }
}

class _FakeRatesCache implements RatesCache {
  @override
  Future<void> clear() async {}

  @override
  Future<void> invalidateHistorical({
    required String base,
    required String quote,
  }) async {}

  @override
  Future<void> invalidateLatest(String base) async {}

  @override
  Future<HistoricalSnapshot?> readHistorical({
    required String base,
    required String quote,
  }) async => null;

  @override
  Future<RatesSnapshot?> readLatest(String base) async => null;

  @override
  Future<void> writeHistorical(HistoricalSnapshot snapshot) async {}

  @override
  Future<void> writeLatest(RatesSnapshot snapshot) async {}
}
