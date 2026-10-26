import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_converter/l10n/app_localizations.dart';
import 'package:currency_converter/src/features/favorites/favorites_screen.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/core/monetization/monetization_controller.dart';

import 'package:currency_converter/src/shared/widgets/swipe_action_button.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:currency_converter/src/features/convert/data/convert_row_hint_store.dart';

void main() {
  testWidgets(
    'swipe tile hides visible label but retains accessible tooltip and tap',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 72,
              child: SwipeActionButton(
                actionKey: const Key('remove'),
                icon: Icons.delete_outline_rounded,
                backgroundColor: Colors.pink.shade50,
                color: Colors.red,
                label: 'Remove currency',
                progress: 1,
                onTap: () => taps++,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Remove'), findsNothing);
      expect(find.byTooltip('Remove currency'), findsOneWidget);
      final target = tester.getSize(find.byType(InkWell));
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
      await tester.tap(find.byKey(const Key('remove')));
      expect(taps, 1);
    },
  );
  test(
    'restoring favorite preserves its previous position and subsequent edits',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');
      final removed = store.pairs[1];
      await store.remove('USD', 'GBP');
      await store.add('USD', 'CHF');
      await store.restore(removed, index: 1);
      expect(store.pairs.map((p) => p.quote), ['EUR', 'GBP', 'JPY', 'CHF']);
      await store.restore(removed, index: 1);
      expect(store.pairs.length, 4);
      expect(FavoritesStore(prefs).pairs, store.pairs);
      store.dispose();
    },
  );
  testWidgets(
    'favorite swipe removal offers Undo and independent hint dismissal persists',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      final controller = ConvertController(
        repository: _NoRates(),
        favoritesStore: store,
      );
      final monetization = MonetizationController(prefs);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FavoritesScreen(
              favoritesStore: store,
              controller: controller,
              monetization: monetization,
              onNavigateToConvert: (_, _) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('favorites_swipe_hint')), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('favorites_swipe_hint')),
          matching: find.byType(IconButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(store.swipeHintSeen, true);
      expect(find.byKey(const Key('favorites_swipe_hint')), findsNothing);
      await tester.drag(
        find.byKey(const Key('open_USD-GBP')),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('remove_USD-GBP')));
      await tester.pumpAndSettle();
      expect(store.isFavorite('USD', 'GBP'), false);
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(store.pairs.map((p) => p.quote), ['EUR', 'GBP']);
      await tester.drag(
        find.byKey(const Key('open_USD-GBP')),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('remove_USD-GBP')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Undo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(store.isFavorite('USD', 'GBP'), false);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      store.dispose();
      monetization.dispose();
    },
  );
  test('opening lens does not mark swipe actions learned', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ConvertRowHintStore(await SharedPreferences.getInstance());
    await store.markSeen();
    expect(store.swipeSeen, false);
    await store.markSwipeSeen();
    expect(store.swipeSeen, true);
  });
}

class _NoRates implements ConvertRatesRepository {
  @override
  Future<LatestRatesSnapshot?> readCached(String base) async => null;
  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async =>
      throw StateError('not used');
  @override
  Future<void> cacheSnapshot(LatestRatesSnapshot snapshot) async {}
  @override
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) async => null;
}
