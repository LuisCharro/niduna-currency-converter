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
import 'package:currency_converter/src/features/charts/widgets/chart_currency_picker_sheet.dart';
import 'package:currency_converter/src/features/charts/widgets/locked_pair_action_sheet.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/charts/presentation/charts_controller.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:currency_converter/src/features/favorites/favorites_screen.dart';
import 'package:currency_converter/src/features/convert/convert_screen.dart';
import 'package:currency_converter/src/features/convert/widgets/ad_support_shelf.dart';
import 'package:currency_converter/src/features/charts/widgets/rate_chart.dart';
import 'package:currency_converter/src/features/settings/settings_screen.dart';
import 'package:currency_converter/src/shared/widgets/bottom_tab_frame.dart';
import 'package:currency_converter/src/shared/widgets/floating_pill_nav.dart';
import 'package:currency_converter/src/shared/widgets/remove_ads_button.dart';

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
    expect(find.textContaining('Fresh'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
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

    expect(find.text('AMOUNT'), findsOneWidget);
    expect(find.textContaining('Fresh'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.textContaining('currencies visible'), findsNothing);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('CHF'), findsNothing);
    expect(find.text('NZD'), findsNothing);
    expect(find.text('BTC'), findsNothing);
    expect(find.text('ETH'), findsNothing);
    expect(find.byType(BottomTabFrame), findsOneWidget);
    expect(find.byType(AdSupportShelf), findsOneWidget);
    expect(find.byType(RemoveAdsButton), findsOneWidget);
  });

  testWidgets('Convert amount input uses sheet keypad and presets', (
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

    await tester.tap(find.text('100.00'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('1K'), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();

    expect(controller.state.amountText, '5');
    expect(controller.state.quotes.first.amount, '4.60');

    await tester.tap(find.text('.'));
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(controller.state.amountText, '5.2');

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();

    expect(controller.state.amountText, '5.');

    await tester.tap(find.text('1K'));
    await tester.pumpAndSettle();

    expect(controller.state.amountText, '1000');
    expect(controller.state.quotes.first.amount, '920.00');

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsNothing);
  });

  testWidgets('Convert daily rates info opens from compact status', (
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

    await tester.tap(find.textContaining('Fresh'));
    await tester.pumpAndSettle();

    expect(find.text('Daily exchange rates'), findsOneWidget);
    expect(
      find.textContaining('not minute-by-minute market prices'),
      findsOneWidget,
    );
    expect(find.textContaining('shown in your local time'), findsOneWidget);
    expect(find.textContaining('future Premium subscription'), findsOneWidget);
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

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Visible currencies'), findsOneWidget);
    expect(find.text('3 shown · USD base'), findsOneWidget);
    expect(find.text('USD · base currency'), findsOneWidget);
    expect(find.text('EUR · shown now'), findsOneWidget);
    expect(find.text('Currency, country, or code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Convert row swipe actions remove the tap-again flow and swap base', (
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

    final euroFinder = find.text('Euro');
    expect(euroFinder, findsWidgets);

    await tester.drag(euroFinder.first, const Offset(-160, 0));
    await tester.pumpAndSettle();

    expect(find.text('Set as base'), findsNothing);
    expect(find.byKey(const Key('swap_EUR')), findsOneWidget);
    expect(controller.state.base, 'USD');

    await tester.tap(find.byKey(const Key('swap_EUR')));
    await tester.pumpAndSettle();

    expect(controller.state.base, 'EUR');
    expect(find.byKey(const Key('swap_EUR')), findsNothing);
  });

  testWidgets('Convert crypto row can be swapped into base from swipe action', (
    WidgetTester tester,
  ) async {
    final cryptoRepository = _FakeRatesRepository(
      fresh: _snapshot(<String, double>{
        'EUR': .92,
        'BTC': .00001342,
      }),
    );
    final cryptoController = ConvertController(repository: cryptoRepository)
      ..configure(base: 'USD', amount: 100, selectedCodes: <String>['EUR']);
    await cryptoController.load();

    await tester.pumpWidget(
      MaterialApp(
        home: ConvertScreen(
          controller: cryptoController,
          monetization: monetization,
          onNavigateToSettings: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bitcoinFinder = find.text('Bitcoin');
    expect(bitcoinFinder, findsWidgets);

    await tester.drag(bitcoinFinder.first, const Offset(-160, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('swap_BTC')), findsOneWidget);
    expect(cryptoController.state.base, 'USD');

    await tester.tap(find.byKey(const Key('swap_BTC')));
    await tester.pumpAndSettle();

    expect(cryptoController.state.base, 'BTC');
    expect(find.text('Set as base'), findsNothing);
    expect(cryptoController.state.quotes, isNotEmpty);
    expect(find.text('Euro'), findsWidgets);

    cryptoController.dispose();
  });

  testWidgets('Convert row swipe action removes currency from visible list', (
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

    final euroFinder = find.text('Euro');
    expect(euroFinder, findsWidgets);

    await tester.drag(euroFinder.first, const Offset(-160, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('remove_EUR')), findsOneWidget);

    await tester.tap(find.byKey(const Key('remove_EUR')));
    await tester.pumpAndSettle();

    expect(find.text('Euro'), findsNothing);
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
    expect(find.text('No saved pairs yet'), findsOneWidget);
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
    expect(find.text('Data & sources'), findsOneWidget);
  });

  testWidgets('Charts screen reuses shared remove ads button', (
    WidgetTester tester,
  ) async {
    final chartsController = ChartsController(
      allowCryptoCharts: true,
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

    expect(find.byType(BottomTabFrame), findsOneWidget);
    expect(find.byType(AdSupportShelf), findsOneWidget);
    expect(find.byType(RemoveAdsButton), findsOneWidget);
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
              currencySymbol: r'$',
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
    expect(data.lineTouchData.handleBuiltInTouches, isFalse);
    expect(data.lineTouchData.touchSpotThreshold, greaterThanOrEqualTo(40));
    expect(data.lineBarsData.first.dotData.show, isTrue);

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

  testWidgets('Charts screen removes helper copy when ads are hidden', (
    WidgetTester tester,
  ) async {
    await monetization.setRemoveAdsLifetime(true);
    final chartsController = ChartsController(
      allowCryptoCharts: true,
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

    expect(
      find.text('Tap currencies above to explore other pairs'),
      findsNothing,
    );

    expect(find.byType(BottomTabFrame), findsOneWidget);
    expect(find.byType(AdSupportShelf), findsNothing);
  });

  testWidgets('Locked chart pair hides rewarded ad when unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LockedPairActionSheet(
            canWatchAd: false,
            onWatchAd: () {},
            onBuyForever: () {},
          ),
        ),
      ),
    );

    expect(find.text('Watch ad · Unlock for 24h'), findsNothing);
    expect(find.text('Unlock all pairs forever'), findsOneWidget);
    expect(
      find.text('Rewarded ads are unavailable after Remove Ads'),
      findsOneWidget,
    );
  });

  testWidgets('Locked chart pair offers rewarded ad for free users', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LockedPairActionSheet(
            canWatchAd: true,
            onWatchAd: () {},
            onBuyForever: () {},
          ),
        ),
      ),
    );

    expect(find.text('Watch ad · Unlock for 24h'), findsOneWidget);
    expect(find.text('Unlock all pairs forever'), findsOneWidget);
  });

  testWidgets('chart picker keeps USD and EUR selectable for crypto pairs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartCurrencyPickerSheet(
            title: 'Select quote currency',
            selectedCode: 'BTC',
            allowCryptoCharts: true,
            controller: monetization,
            baseCurrency: 'ETH',
            quoteCurrency: 'BTC',
            selectingBase: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final eurTile = find.ancestor(
      of: find.text('EUR'),
      matching: find.byType(InkWell),
    );
    final usdTile = find.ancestor(
      of: find.text('USD'),
      matching: find.byType(InkWell),
    );

    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(
      find.descendant(of: eurTile, matching: find.text('Tap to unlock')),
      findsNothing,
    );
    expect(
      find.descendant(of: usdTile, matching: find.text('Tap to unlock')),
      findsNothing,
    );
    expect(
      find.descendant(of: eurTile, matching: find.text('Locked')),
      findsNothing,
    );
    expect(
      find.descendant(of: usdTile, matching: find.text('Locked')),
      findsNothing,
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
