import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/features/convert/data/convert_row_hint_store.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/convert/widgets/convert_content.dart';
import 'package:currency_converter/src/features/convert/widgets/convert_row_actions_hint.dart';
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

  Widget host(ConvertRowHintStore? store) {
    return MaterialApp(
      home: Scaffold(
        body: ConvertContent(
          state: controller.state,
          onRefresh: controller.refresh,
          onAmountChanged: controller.setAmountText,
          onSelectBase: controller.setBase,
          onToggleCode: controller.toggleCode,
          onToggleFavorite: controller.tryToggleFavorite,
          onMore: () {},
          onShare: () {},
          hintStore: store,
        ),
      ),
    );
  }

  testWidgets('hint is shown on a fresh store (prefs.clear())', (
    tester,
  ) async {
    await prefs.clear();
    await tester.pumpWidget(host(ConvertRowHintStore(prefs)));
    await tester.pumpAndSettle();
    expect(find.byType(ConvertRowActionsHint), findsOneWidget);
    expect(
      find.byKey(const Key('convert_row_EUR')),
      findsOneWidget,
      reason: 'row keys must survive the hint being present',
    );
  });

  testWidgets('dismissing the hint hides it and persists', (tester) async {
    await prefs.clear();
    final store = ConvertRowHintStore(prefs);
    expect(store.seen, isFalse);
    await tester.pumpWidget(host(store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('convert_row_actions_hint_dismiss')));
    await tester.pumpAndSettle();

    expect(find.byType(ConvertRowActionsHint), findsNothing);
    expect(store.seen, isTrue);
  });

  testWidgets('hint does not show once already marked seen', (tester) async {
    await prefs.clear();
    final store = ConvertRowHintStore(prefs);
    await store.markSeen();
    await tester.pumpWidget(host(store));
    await tester.pumpAndSettle();
    expect(find.byType(ConvertRowActionsHint), findsNothing);
  });

  testWidgets('no hint store disables the hint entirely', (tester) async {
    await tester.pumpWidget(host(null));
    await tester.pumpAndSettle();
    expect(find.byType(ConvertRowActionsHint), findsNothing);
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
