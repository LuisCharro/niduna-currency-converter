import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair_rate.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_reverse_rate.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorite_hero_card.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorite_pair_row.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_empty_slot.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_empty_state.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_list.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_section_header.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_upgrade_pill.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_upgrade_row.dart';
import 'package:currency_converter/src/shared/widgets/overlapping_flag_pair.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: ListView(children: <Widget>[child])),
  );

  LatestRatesSnapshot snapshot({
    required Map<String, double> rates,
    Map<String, double>? previousRates,
  }) => LatestRatesSnapshot(
    base: 'USD',
    date: DateTime(2026, 9, 29),
    savedAt: DateTime(2026, 9, 29, 9),
    rates: rates,
    previousRates: previousRates,
  );

  group('formatFavoriteRate', () {
    test('uses 2 decimals >= 100 and drops an all-zero fraction', () {
      expect(formatFavoriteRate(83195.0), '83,195');
    });

    test('uses 4 decimals >= 0.1', () {
      expect(formatFavoriteRate(1.137), '1.1370');
    });

    test('uses up to 8 decimals below 0.1 and strips trailing zeros', () {
      expect(formatFavoriteRate(0.000015), '0.000015');
    });
  });

  group('reverseRateFor', () {
    test('is the reciprocal of a positive rate', () {
      expect(reverseRateFor(0.8), 1.25);
    });

    test('is null for a null or zero rate', () {
      expect(reverseRateFor(null), isNull);
      expect(reverseRateFor(0), isNull);
    });
  });

  group('favoriteReverseRateLine', () {
    const pair = FavoritePair(base: 'USD', quote: 'EUR');

    test('reads "1 QUOTE = X BASE"', () {
      expect(
        favoriteReverseRateLine(pair: pair, rate: 0.8),
        '1 EUR = 1.2500 USD',
      );
    });

    test('is null when the rate is missing (no reverse line at all)', () {
      expect(favoriteReverseRateLine(pair: pair, rate: null), isNull);
    });

    test('reads naturally for a crypto quote', () {
      const crypto = FavoritePair(base: 'USD', quote: 'BTC');
      // 1 USD = 0.000012019... BTC -> 1 BTC ~= 83195 USD.
      expect(
        favoriteReverseRateLine(pair: crypto, rate: 1 / 83195),
        '1 BTC = 83,195 USD',
      );
    });
  });

  group('FavoritesList hero vs rows', () {
    List<FavoritePair> pairs() => <FavoritePair>[
      const FavoritePair(base: 'USD', quote: 'EUR'),
      const FavoritePair(base: 'USD', quote: 'GBP'),
      const FavoritePair(base: 'USD', quote: 'JPY'),
    ];

    testWidgets('first visible pair is the hero, the rest are rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FavoritesList(
            pairs: pairs(),
            effectiveLimit: 3,
            visibleLimit: 3,
            hasFavoritesPro: false,
            canOfferBoost: false,
            snapshot: null,
            onOpen: (_) {},
            onRemove: (_) {},
            onReorder: (_, _) {},
            onAdd: () {},
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );

      expect(find.byType(FavoriteHeroCard), findsOneWidget);
      expect(find.byType(FavoritePairRow), findsNWidgets(2));
    });

    testWidgets('empty slot only shows when under the effective limit', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FavoritesList(
            pairs: pairs().sublist(0, 2),
            effectiveLimit: 3,
            visibleLimit: 3,
            hasFavoritesPro: false,
            canOfferBoost: false,
            snapshot: null,
            onOpen: (_) {},
            onRemove: (_) {},
            onReorder: (_, _) {},
            onAdd: () {},
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );
      expect(find.byType(FavoritesEmptySlot), findsOneWidget);
      expect(find.byType(FavoritesUpgradeRow), findsNothing);
    });

    testWidgets('upgrade row (not the empty slot) shows once at the limit', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FavoritesList(
            pairs: pairs(),
            effectiveLimit: 3,
            visibleLimit: 3,
            hasFavoritesPro: false,
            canOfferBoost: true,
            snapshot: null,
            onOpen: (_) {},
            onRemove: (_) {},
            onReorder: (_, _) {},
            onAdd: () {},
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );
      expect(find.byType(FavoritesUpgradeRow), findsOneWidget);
      expect(find.byType(FavoritesEmptySlot), findsNothing);
    });
  });

  group('FavoritesUpgradeRow variants', () {
    testWidgets('at-limit variant shows both pills when boost is offered '
        'and there is no Pro', (tester) async {
      await tester.pumpWidget(
        host(
          FavoritesUpgradeRow(
            hiddenCount: 0,
            canOfferBoost: true,
            hasFavoritesPro: false,
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );
      expect(find.text('Want more pairs?'), findsOneWidget);
      expect(find.byType(FavoritesUpgradePill), findsNWidgets(2));
    });

    testWidgets('hides the boost pill when no boost is offered', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FavoritesUpgradeRow(
            hiddenCount: 0,
            canOfferBoost: false,
            hasFavoritesPro: false,
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );
      expect(find.byType(FavoritesUpgradePill), findsNWidgets(1));
    });

    testWidgets('hides the Pro pill once Pro is owned', (tester) async {
      await tester.pumpWidget(
        host(
          FavoritesUpgradeRow(
            hiddenCount: 0,
            canOfferBoost: true,
            hasFavoritesPro: true,
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );
      expect(find.byType(FavoritesUpgradePill), findsNWidgets(1));
    });

    testWidgets('hidden-pairs variant keeps its own copy', (tester) async {
      await tester.pumpWidget(
        host(
          FavoritesUpgradeRow(
            hiddenCount: 4,
            canOfferBoost: true,
            hasFavoritesPro: false,
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );
      expect(find.text('4 pairs hidden'), findsOneWidget);
    });
  });

  testWidgets('FavoritesEmptyState renders the effective limit in its body', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(FavoritesEmptyState(effectiveLimit: 3, onAdd: () {})),
    );
    expect(find.textContaining('3 pairs'), findsOneWidget);
  });

  group('swipe to reveal Remove', () {
    testWidgets('swiping a row left reveals Remove and tapping it calls '
        'onRemove', (tester) async {
      var removed = false;
      const pair = FavoritePair(base: 'USD', quote: 'GBP');

      await tester.pumpWidget(
        host(
          FavoritePairRow(
            pair: pair,
            index: 1,
            snapshot: snapshot(rates: const <String, double>{'GBP': 0.79}),
            onOpen: () {},
            onRemove: () => removed = true,
            onMoveUp: () {},
          ),
        ),
      );

      await tester.drag(find.byType(FavoritePairRow), const Offset(-200, 0));
      await tester.pumpAndSettle();

      final removeButton = find.byKey(Key('remove_${pair.toKey()}'));
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });

    testWidgets('swiping the hero card left reveals Remove too', (
      tester,
    ) async {
      var removed = false;
      const pair = FavoritePair(base: 'USD', quote: 'EUR');

      await tester.pumpWidget(
        host(
          FavoriteHeroCard(
            pair: pair,
            snapshot: snapshot(rates: const <String, double>{'EUR': 0.92}),
            onOpen: () {},
            onRemove: () => removed = true,
          ),
        ),
      );

      await tester.drag(find.byType(FavoriteHeroCard), const Offset(-200, 0));
      await tester.pumpAndSettle();

      final removeButton = find.byKey(Key('remove_${pair.toKey()}'));
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });

    testWidgets('a closed row has no visible/hit-testable Remove rail', (
      tester,
    ) async {
      var removed = false;
      const pair = FavoritePair(base: 'USD', quote: 'GBP');

      await tester.pumpWidget(
        host(
          FavoritePairRow(
            pair: pair,
            index: 1,
            snapshot: snapshot(rates: const <String, double>{'GBP': 0.79}),
            onOpen: () {},
            onRemove: () => removed = true,
            onMoveUp: () {},
          ),
        ),
      );

      // No swipe happened: Remove exists in the tree (built underneath the
      // closed foreground) but must be ignored by hit-testing, not tappable.
      final removeButton = find.byKey(Key('remove_${pair.toKey()}'));
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(removed, isFalse);
    });
  });

  group('row alignment at 360dp', () {
    testWidgets(
      'row content (flags) lines up with the "MORE PAIRS" label and the '
      'hero card, not indented further',
      (tester) async {
        tester.view.physicalSize = const Size(360, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Mirrors FavoritesTabBody: the whole list sits inside the page's
        // horizontal insets, and nothing inside a row should add more.
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: AppTheme.pageInsets,
                child: FavoritesList(
                  pairs: <FavoritePair>[
                    const FavoritePair(base: 'USD', quote: 'EUR'),
                    const FavoritePair(base: 'USD', quote: 'GBP'),
                  ],
                  effectiveLimit: 3,
                  visibleLimit: 3,
                  hasFavoritesPro: false,
                  canOfferBoost: false,
                  snapshot: null,
                  onOpen: (_) {},
                  onRemove: (_) {},
                  onReorder: (_, _) {},
                  onAdd: () {},
                  onWatchAd: () {},
                  onBuyPro: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final labelLeft = tester
            .getTopLeft(find.byType(FavoritesSectionHeader))
            .dx;
        final rowFlagsLeft = tester
            .getTopLeft(
              find.descendant(
                of: find.byType(FavoritePairRow),
                matching: find.byType(OverlappingFlagPair),
              ),
            )
            .dx;
        expect(rowFlagsLeft, labelLeft);
      },
    );
  });

  group('row layout at 360x640, text scale 2.0', () {
    Future<void> pumpAt360x640Scale2(WidgetTester tester, Widget child) {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(body: ListView(children: <Widget>[child])),
          ),
        ),
      );
    }

    testWidgets(
      'a row has no overflow exceptions and its trend text stays inside '
      'the row bounds',
      (tester) async {
        const pair = FavoritePair(base: 'USD', quote: 'EUR');
        await pumpAt360x640Scale2(
          tester,
          FavoritePairRow(
            pair: pair,
            index: 1,
            snapshot: snapshot(
              rates: const <String, double>{'EUR': 0.8634},
              previousRates: const <String, double>{'EUR': 0.8645},
            ),
            onOpen: () {},
            onRemove: () {},
            onMoveUp: () {},
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // The row's own box is a known, finite height (RenderFlex would have
        // thrown above if anything inside it needed more). Checking the
        // trend Text's own render size (rather than its global rect, which
        // walks paint transforms this swipe stack deliberately animates)
        // confirms it laid out to a normal, finite, on-screen size instead
        // of being clipped down to nothing or overflowing unboundedly.
        final rowSize = tester.getSize(find.byType(FavoritePairRow));
        expect(rowSize.height, FavoritePairRow.rowHeight + .5);

        final trendBox = tester.renderObject<RenderBox>(
          find.textContaining('%'),
        );
        expect(trendBox.size.width, greaterThan(0));
        expect(trendBox.size.height, greaterThan(0));
        expect(trendBox.size.height, lessThan(FavoritePairRow.rowHeight));
      },
    );

    Future<void> pumpAt360x640(
      WidgetTester tester,
      Widget child,
      double scale,
    ) {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(body: ListView(children: <Widget>[child])),
          ),
        ),
      );
    }

    for (final scale in <double>[1.0, 2.0]) {
      testWidgets(
        'a long crypto value does not truncate the title at scale $scale '
        '("USD → BTC" fully renders)',
        (tester) async {
          const pair = FavoritePair(base: 'USD', quote: 'BTC');
          await pumpAt360x640(
            tester,
            FavoritePairRow(
              pair: pair,
              index: 1,
              snapshot: snapshot(
                rates: const <String, double>{'BTC': 0.00001202},
              ),
              onOpen: () {},
              onRemove: () {},
              onMoveUp: () {},
            ),
            scale,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          final titleFinder = find.text('USD → BTC');
          expect(titleFinder, findsOneWidget);
          final renderText = tester.renderObject<RenderParagraph>(titleFinder);
          expect(renderText.didExceedMaxLines, isFalse);
        },
      );
    }
  });

  group('FavoriteHeroCard compact mode', () {
    Future<void> pumpHeroAtHeight(WidgetTester tester, double height) {
      tester.view.physicalSize = Size(360, height);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: FavoriteHeroCard(
              pair: const FavoritePair(base: 'USD', quote: 'EUR'),
              snapshot: snapshot(rates: const <String, double>{'EUR': 0.92}),
              onOpen: () {},
              onRemove: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('uses the compact rate size on a short screen and fits its '
        'content (no leftover empty space)', (tester) async {
      await pumpHeroAtHeight(tester, 640);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final heroSize = tester.getSize(find.byType(FavoriteHeroCard));
      // Content-fitted (title row + rate + reverse line + freshness line +
      // tighter padding), not the old fixed 168 box that left empty space.
      expect(heroSize.height, lessThan(170));

      final rateText = tester.widgetList<Text>(find.text('0.9200')).first;
      expect(rateText.style?.fontSize, 36);
    });

    testWidgets('uses the normal rate size on a tall screen, and is still '
        'shorter than the old fixed box (no leftover empty space)', (
      tester,
    ) async {
      await pumpHeroAtHeight(tester, 900);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final heroSize = tester.getSize(find.byType(FavoriteHeroCard));
      // The old fixed height was 216 and left ~30-100px empty below the
      // freshness line depending on device height; content-fitted sizing
      // must land comfortably under that.
      expect(heroSize.height, lessThan(200));

      final rateText = tester.widgetList<Text>(find.text('0.9200')).first;
      expect(rateText.style?.fontSize, isNot(36));
    });

    testWidgets('the compact card is shorter than the normal card', (
      tester,
    ) async {
      await pumpHeroAtHeight(tester, 640);
      await tester.pumpAndSettle();
      final compactHeight = tester
          .getSize(find.byType(FavoriteHeroCard))
          .height;

      await pumpHeroAtHeight(tester, 900);
      await tester.pumpAndSettle();
      final normalHeight = tester.getSize(find.byType(FavoriteHeroCard)).height;

      expect(compactHeight, lessThan(normalHeight));
    });
  });
}
