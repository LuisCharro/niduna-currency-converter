import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/convert/widgets/amount_panel.dart';
import 'package:currency_converter/src/features/convert/widgets/convert_content.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';

void main() {
  late SharedPreferences prefs;
  late ConvertController controller;

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
    await controller.load();
  });

  tearDown(() => controller.dispose());

  Widget host(Size size, {double textScale = 1}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: ConvertContent(
            state: controller.state,
            onRefresh: controller.refresh,
            onAmountChanged: controller.setAmountText,
            onSelectBase: controller.setBase,
            onToggleCode: controller.toggleCode,
            onToggleFavorite: controller.tryToggleFavorite,
            onMore: () {},
            onShare: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('short screens (<700dp) use the compact amount panel', (
    tester,
  ) async {
    await tester.pumpWidget(host(const Size(360, 640)));
    await tester.pumpAndSettle();
    final panel = tester.widget<AmountPanel>(find.byType(AmountPanel));
    expect(panel.compact, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tall screens keep the normal amount panel', (tester) async {
    await tester.pumpWidget(host(const Size(411, 914)));
    await tester.pumpAndSettle();
    final panel = tester.widget<AmountPanel>(find.byType(AmountPanel));
    expect(panel.compact, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact layout does not overflow at text scale 2.0', (
    tester,
  ) async {
    await tester.pumpWidget(host(const Size(360, 640), textScale: 2));
    await tester.pumpAndSettle();
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

  @override
  Future<void> cacheSnapshot(LatestRatesSnapshot snapshot) async {}

  @override
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) async => null;
}
