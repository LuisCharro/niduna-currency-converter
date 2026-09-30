import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/domain/favorites_reorder_index.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorite_hero_card.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorite_pair_row.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_list.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: ListView(children: <Widget>[child])),
  );

  List<FavoritePair> threePairs() => <FavoritePair>[
    const FavoritePair(base: 'USD', quote: 'EUR'),
    const FavoritePair(base: 'USD', quote: 'GBP'),
    const FavoritePair(base: 'USD', quote: 'JPY'),
  ];

  testWidgets('renders the first pair as a hero card and the rest as rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FavoritesList(
          pairs: threePairs(),
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

  testWidgets('only renders the visible slice as hero + rows', (tester) async {
    await tester.pumpWidget(
      host(
        FavoritesList(
          pairs: threePairs(),
          effectiveLimit: 3,
          visibleLimit: 2,
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
    expect(find.byType(FavoritePairRow), findsNWidgets(1));
  });

  testWidgets(
    'long-press-dragging a row calls onReorder (drag-to-reorder is wired up)',
    (tester) async {
      var reorderCalled = false;

      await tester.pumpWidget(
        host(
          FavoritesList(
            pairs: threePairs(),
            effectiveLimit: 3,
            visibleLimit: 3,
            hasFavoritesPro: false,
            canOfferBoost: false,
            snapshot: null,
            onOpen: (_) {},
            onRemove: (_) {},
            onReorder: (_, _) => reorderCalled = true,
            onAdd: () {},
            onWatchAd: () {},
            onBuyPro: () {},
          ),
        ),
      );

      // JPY is the last row; long-press then drag it up past the hero card.
      final jpyRow = find.byWidgetPredicate(
        (w) =>
            w is FavoritePairRow &&
            w.pair == const FavoritePair(base: 'USD', quote: 'JPY'),
      );
      expect(jpyRow, findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(jpyRow));
      await tester.pump(kLongPressTimeout + kPressTimeout);
      await gesture.moveBy(const Offset(0, -400));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(reorderCalled, isTrue);
    },
  );

  group('favoritesChildToPairIndex', () {
    // children = [hero(0), header(1), row(2)=pair1, row(3)=pair2, ...]
    test('is the identity when there is no header (a single visible pair)', () {
      expect(favoritesChildToPairIndex(0, hasHeader: false), 0);
      expect(favoritesChildToPairIndex(1, hasHeader: false), 1);
    });

    test('hero (0) and the header slot (1) both pass through unchanged', () {
      expect(favoritesChildToPairIndex(0, hasHeader: true), 0);
      expect(favoritesChildToPairIndex(1, hasHeader: true), 1);
    });

    test('rows after the header shift back by one', () {
      expect(favoritesChildToPairIndex(2, hasHeader: true), 1);
      expect(favoritesChildToPairIndex(3, hasHeader: true), 2);
      // "end + 1", ReorderableListView's convention for "append at the end".
      expect(favoritesChildToPairIndex(4, hasHeader: true), 3);
    });
  });
}
