import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/widgets/trend_badge.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorite_pair_row.dart';

// Verifies the Favorites row renders the trend badge for a real day-over-day
// move and hides it when flat — without a device tap.
void main() {
  LatestRatesSnapshot snapshot({
    required Map<String, double> rates,
    Map<String, double>? previousRates,
  }) =>
      LatestRatesSnapshot(
        base: 'USD',
        date: DateTime(2026, 6, 15),
        savedAt: DateTime(2026, 6, 15, 9),
        rates: rates,
        previousRates: previousRates,
      );

  Future<void> pumpRow(WidgetTester tester, LatestRatesSnapshot snap) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: FavoritePairRow(
            pair: const FavoritePair(base: 'USD', quote: 'EUR'),
            index: 0,
            snapshot: snap,
            showDivider: false,
            onOpen: () {},
            onRemove: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the trend badge on a real move', (tester) async {
    await pumpRow(
      tester,
      snapshot(
        rates: const <String, double>{'EUR': 0.8634},
        previousRates: const <String, double>{'EUR': 0.8645},
      ),
    );
    expect(find.byType(TrendBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides the badge when there is no previous rate', (tester) async {
    await pumpRow(tester, snapshot(rates: const <String, double>{'EUR': 0.8634}));
    expect(find.byType(TrendBadge), findsNothing);
  });

  testWidgets('hides the badge when flat', (tester) async {
    await pumpRow(
      tester,
      snapshot(
        rates: const <String, double>{'EUR': 0.8634},
        previousRates: const <String, double>{'EUR': 0.8634},
      ),
    );
    expect(find.byType(TrendBadge), findsNothing);
  });
}
