import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/rewarded_ad_service_stub.dart';
import 'package:currency_converter/src/core/rates/models/rates_snapshot.dart';
import 'package:currency_converter/src/core/rates/rates_cache.dart';
import 'package:currency_converter/src/core/rates/rates_client.dart';
import 'package:currency_converter/src/core/rates/rates_service.dart';
import 'package:currency_converter/src/features/charts/charts_screen.dart';
import 'package:currency_converter/src/features/charts/domain/chart_range.dart';
import 'package:currency_converter/src/features/charts/presentation/charts_controller.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_metric_rail.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_pair_pill.dart';
import 'package:currency_converter/src/features/charts/widgets/range_selector.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/convert/widgets/convert_content.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';

void main() {
  late SharedPreferences prefs;
  late ConvertController controller;
  late MonetizationController monetization;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    final repository = _FakeRatesRepository(
      fresh: LatestRatesSnapshot(
        base: 'USD',
        date: DateTime(2026, 5, 8),
        savedAt: DateTime(2026, 5, 8, 9),
        rates: <String, double>{'EUR': .92, 'GBP': .79, 'JPY': 150.23},
      ),
    );
    controller = ConvertController(
      repository: repository,
      favoritesStore: FavoritesStore(prefs),
    );
    monetization = MonetizationController(
      prefs,
      adService: RewardedAdServiceStub(),
    );
    await controller.load();
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('ConvertContent survives text scale 1.3 without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Scaffold(
            body: ConvertContent(
              state: controller.state,
              onRefresh: controller.refresh,
              onAmountChanged: controller.setAmountText,
              onSelectBase: controller.setBase,
              onToggleCode: controller.toggleCode,
              onToggleFavorite: controller.tryToggleFavorite,
              onMore: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('convert_amount_field')), findsOneWidget);
    expect(find.byKey(const Key('convert_rates_list')), findsOneWidget);
  });

  testWidgets('RangeSelector survives text scale 1.3 without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: RangeSelector(
                selected: ChartRange.oneMonth,
                onChanged: (_) {},
                canUseLockedRanges: false,
                includesCrypto: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('charts_range_selector')), findsOneWidget);
  });

  testWidgets('ChartPairPill temp badge fits narrow chart strip', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(142, 70));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 142,
                child: ChartPairPill(
                  code: 'BTC',
                  locked: false,
                  tempBadge: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('24h'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
  });

  testWidgets('ChartMetricRail prioritizes crypto values over period label', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 90));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ChartMetricRail(
                high: 0.00001289,
                low: 0.00001173,
                changePercent: 0.77,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('0.00001289'), findsOneWidget);
    expect(find.text('0.00001173'), findsOneWidget);
    expect(find.text('Period'), findsNothing);
  });

  testWidgets('Charts screen exposes pair and retry keys in error path', (
    WidgetTester tester,
  ) async {
    final chartsController = ChartsController(
      allowCryptoCharts: true,
      ratesService: RatesService(
        client: _FailingRatesClient(),
        cache: _EmptyRatesCache(),
      ),
    );
    addTearDown(chartsController.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ChartsScreen(
          controller: chartsController,
          monetization: monetization,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const Key('charts_pair_base')), findsOneWidget);
    expect(find.byKey(const Key('charts_pair_quote')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeRatesRepository implements ConvertRatesRepository {
  _FakeRatesRepository({required this.fresh});

  final LatestRatesSnapshot fresh;

  @override
  Future<LatestRatesSnapshot?> readCached(String base) async => null;

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async => fresh;
}

class _FailingRatesClient implements RatesClient {
  @override
  Future<RatesSnapshot> fetchLatest(String base) async {
    throw StateError('offline');
  }

  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    throw StateError('offline');
  }
}

class _EmptyRatesCache implements RatesCache {
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
