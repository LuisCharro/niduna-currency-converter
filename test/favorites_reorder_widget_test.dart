import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_list.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(children: <Widget>[child]),
        ),
      );

  testWidgets('renders a drag handle for each visible favorite', (tester) async {
    final pairs = <FavoritePair>[
      const FavoritePair(base: 'USD', quote: 'EUR'),
      const FavoritePair(base: 'USD', quote: 'GBP'),
      const FavoritePair(base: 'USD', quote: 'JPY'),
    ];

    await tester.pumpWidget(host(
      FavoritesList(
        pairs: pairs,
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
    ));

    expect(find.byIcon(Icons.drag_handle), findsNWidgets(3));
  });

  testWidgets('only renders handles for the visible slice', (tester) async {
    final pairs = <FavoritePair>[
      const FavoritePair(base: 'USD', quote: 'EUR'),
      const FavoritePair(base: 'USD', quote: 'GBP'),
      const FavoritePair(base: 'USD', quote: 'JPY'),
    ];

    await tester.pumpWidget(host(
      FavoritesList(
        pairs: pairs,
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
    ));

    expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
  });
}
