import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/convert/models/currency_quote.dart';
import 'package:currency_converter/src/features/convert/widgets/currency_rate_row.dart';
import 'package:currency_converter/src/features/convert/widgets/trend_badge.dart';

// Regression guard for the trend badge (task #1).
//
// The trend badge used to be a 3rd stacked line in the rate value column.
// Every Convert row is pinned to a fixed AppTheme.rowMinHeight (64px) by
// CurrencyRowSwipeActions, so the 3rd line overflowed the row by 18px and the
// badge was clipped off the bottom on-device. The fix moves the badge inline,
// to the left of the rate value, keeping the row at 2 lines. These tests pump
// a row under the real 64px constraint and assert it does NOT overflow — which
// is exactly what the original layout failed.
void main() {
  setUpAll(() async {
    // Load real Manrope so text widths match the device; the test "Ahem" font
    // renders every glyph as a full-em square, which fabricates overflow.
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

  CurrencyQuote quote(
    String symbol,
    String code,
    String name,
    String amount,
    String rateLine, {
    required double rate,
    double? previousRate,
  }) => CurrencyQuote(
    symbol,
    code,
    name,
    amount,
    rateLine,
    rate: rate,
    previousRate: previousRate,
  );

  // Up / down / flat / long-crypto-value — the cases that stress the row.
  // Rows with a meaningful move — the badge must render (and still fit 64px).
  final withBadge = <CurrencyQuote>[
    quote('€', 'EUR', 'Euro', '86.45', '1 USD = 0.86 EUR',
        rate: 0.8645, previousRate: 0.8590), // up
    quote('£', 'GBP', 'British Pound', '74.62', '1 USD = 0.75 GBP',
        rate: 0.7462, previousRate: 0.7530), // down
    quote('₿', 'BTC', 'Bitcoin', '0.00155611', '1 USD = 0.0000155 BTC',
        rate: 0.0000155, previousRate: 0.0000149), // up, long crypto value
  ];

  // Rows with no meaningful move — the badge must be hidden.
  final withoutBadge = <CurrencyQuote>[
    quote('¥', 'JPY', 'Japanese Yen', '16,037.00', '1 USD = 160.37 JPY',
        rate: 160.37, previousRate: 160.37), // flat (weekend: today == prev)
    quote('\$', 'CAD', 'Canadian Dollar', '136.50', '1 USD = 1.37 CAD',
        rate: 1.3650, previousRate: 1.36495), // change rounds to 0.00%
    quote('€', 'EUR', 'Euro', '86.45', '1 USD = 0.86 EUR',
        rate: 0.8645), // no previous rate at all
  ];

  Future<void> pumpRow(WidgetTester tester, CurrencyQuote q, ThemeData theme) {
    tester.view.physicalSize = const Size(1080, 200);
    tester.view.devicePixelRatio = 2.625; // Pixel 7 → 411dp wide
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Mirror the real list: the row is pinned to 64px.
              child: SizedBox(
                height: AppTheme.rowMinHeight,
                child: CurrencyRateRow(quote: q),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final theme in <(String, ThemeData)>[
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    for (final q in withBadge) {
      testWidgets('${q.code} trend badge shows and fits 64px (${theme.$1})',
          (tester) async {
        await pumpRow(tester, q, theme.$2);
        await tester.pumpAndSettle();

        // The badge is rendered...
        expect(find.byType(TrendBadge), findsOneWidget);
        // ...and nothing overflowed the fixed-height row.
        expect(tester.takeException(), isNull);
      });
    }

    for (final q in withoutBadge) {
      testWidgets('${q.code} hides badge when flat/0.00% (${theme.$1})',
          (tester) async {
        await pumpRow(tester, q, theme.$2);
        await tester.pumpAndSettle();

        expect(find.byType(TrendBadge), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
