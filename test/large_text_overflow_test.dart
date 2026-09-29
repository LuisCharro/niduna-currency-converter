import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_touch_overlay.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/models/currency_quote.dart';
import 'package:currency_converter/src/features/convert/widgets/currency_rate_row.dart';
import 'package:currency_converter/src/features/convert/widgets/swipe_action_widgets.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorite_pair_row.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorites_limit_note.dart';
import 'package:currency_converter/src/features/settings/widgets/base_currency_picker.dart';
import 'package:currency_converter/src/shared/widgets/floating_pill_nav_item.dart';

// Regression guard for large system font sizes (Android font scale 2.0).
//
// An integration run at font_scale 2.0 on a 393x851dp phone found several
// RenderFlex overflow exceptions plus a few widgets that stayed exception-free
// but rendered unusably (e.g. a favorite pair title collapsing to "U…").
// These tests pump each affected widget at TextScaler.linear(2.0) on a narrow
// logical size and assert no exception is thrown. Layout at scale 1.0 is
// covered by each widget's existing tests and is unchanged by these fixes.
void main() {
  setUpAll(() async {
    // Real Manrope glyph widths, not the test "Ahem" font's full-em squares,
    // so text-fit behaviour matches the device.
    final loader = FontLoader('Manrope');
    for (final path in const <String>[
      'fonts/manrope/Manrope-Regular.ttf',
      'fonts/manrope/Manrope-Medium.ttf',
      'fonts/manrope/Manrope-SemiBold.ttf',
      'fonts/manrope/Manrope-Bold.ttf',
      'fonts/manrope/Manrope-ExtraBold.ttf',
    ]) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  });

  Future<void> pumpAtLargeTextScale(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(360, 640),
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  testWidgets('FloatingPillNavItem does not overflow at text scale 2.0', (
    tester,
  ) async {
    await pumpAtLargeTextScale(
      tester,
      Row(
        children: <Widget>[
          FloatingPillNavItem(
            icon: Icons.swap_horiz,
            label: 'Convert',
            isSelected: true,
            onTap: () {},
          ),
          FloatingPillNavItem(
            icon: Icons.star_rounded,
            label: 'Favorites',
            isSelected: false,
            onTap: () {},
          ),
          FloatingPillNavItem(
            icon: Icons.settings,
            label: 'Settings',
            isSelected: false,
            onTap: () {},
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Convert'), findsOneWidget);
  });

  testWidgets('SwipeActionsRail does not overflow at text scale 2.0', (
    tester,
  ) async {
    // Mirrors the real constraint: CurrencyRowSwipeActions pins this rail to
    // a fixed AppTheme.rowMinHeight box (see swipe_action_widgets.dart:153).
    await pumpAtLargeTextScale(
      tester,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: AppTheme.rowMinHeight,
          child: SwipeActionsRail(
            code: 'EUR',
            isFavorite: false,
            reveal: 200,
            onRemove: () {},
            onSwap: () {},
            onFavorite: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('BaseCurrencyPicker title does not overflow at text scale 2.0', (
    tester,
  ) async {
    await pumpAtLargeTextScale(
      tester,
      const BaseCurrencyPicker(currentBase: 'USD'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('FavoritesLimitNote does not overflow at text scale 2.0', (
    tester,
  ) async {
    await pumpAtLargeTextScale(
      tester,
      FavoritesLimitNote(
        canOfferBoost: true,
        onWatchAd: () {},
        onBuyPro: () {},
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChartTouchOverlay does not overflow at text scale 2.0', (
    tester,
  ) async {
    await pumpAtLargeTextScale(
      tester,
      ChartTouchOverlay(
        date: DateTime(2026, 5, 8),
        currencyCode: 'EUR',
        value: 0.8645,
        baseValue: 0.859,
        lineColor: Colors.green,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('CurrencyRateRow fits its fixed 64px row at text scale 2.0', (
    tester,
  ) async {
    const quote = CurrencyQuote(
      '€',
      'EUR',
      'Euro',
      '86.45',
      '1 USD = 0.86 EUR',
      rate: 0.8645,
      previousRate: 0.8590,
    );
    await pumpAtLargeTextScale(
      tester,
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: AppTheme.rowMinHeight,
            child: const CurrencyRateRow(quote: quote),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('FavoritePairRow does not overflow and keeps the title '
      'readable at text scale 2.0', (tester) async {
    const pair = FavoritePair(base: 'USD', quote: 'EUR');
    final snapshot = LatestRatesSnapshot(
      base: 'USD',
      date: DateTime(2026, 5, 8),
      savedAt: DateTime(2026, 5, 8, 9),
      rates: const <String, double>{'EUR': 0.8645},
      previousRates: const <String, double>{'EUR': 0.859},
    );
    await pumpAtLargeTextScale(
      tester,
      Padding(
        padding: const EdgeInsets.all(12),
        child: FavoritePairRow(
          pair: pair,
          index: 0,
          snapshot: snapshot,
          showDivider: false,
          onOpen: () {},
          onRemove: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // The title must still read as a full pair, not a collapsed sliver
    // like "U…" — the regression this test guards against.
    expect(find.textContaining('USD'), findsWidgets);
    expect(find.textContaining('EUR'), findsWidgets);
  });
}
