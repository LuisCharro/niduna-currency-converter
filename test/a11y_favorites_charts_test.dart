import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/l10n/app_localizations.dart';
import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/domain/chart_range.dart';
import 'package:currency_converter/src/features/charts/widgets/range_selector.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/widgets/favorite_pair_row.dart';

void main() {
  // -------------------------------------------------------------------------
  // Favorites row
  // -------------------------------------------------------------------------
  group('FavoritePairRow semantics', () {
    Future<void> pumpRow(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FavoritePairRow(
              pair: const FavoritePair(base: 'USD', quote: 'EUR'),
              index: 0,
              snapshot: LatestRatesSnapshot(
                base: 'USD',
                date: DateTime(2026, 6, 15),
                savedAt: DateTime(2026, 6, 15, 9),
                rates: const <String, double>{'EUR': 0.9},
              ),
              showDivider: false,
              onOpen: () {},
              onRemove: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('open row carries tap action and onTapHint', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpRow(tester);
      // The Semantics(onTapHint:) merges with the InkWell into the first node
      // in the FavoritePairRow subtree that carries a tap action.
      expect(
        tester.getSemantics(find.byType(InkWell).first),
        matchesSemantics(
          hasTapAction: true,
          hasFocusAction: true,
          isButton: true,
          isFocusable: true,
          onTapHint: 'Open pair in Convert',
        ),
      );
      handle.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Range buttons
  // -------------------------------------------------------------------------
  group('RangeSelector semantics', () {
    Future<void> pumpSelector(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RangeSelector(
              selected: ChartRange.oneWeek,
              onChanged: (_) {},
              canUseLockedRanges: false,
              includesCrypto: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('selected 1W range button is a selected button with tap action',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSelector(tester);

      // hasSelectedState is set by Flutter when selected: is provided.
      final semanticsNode = tester.getSemantics(find.bySemanticsLabel('1W range'));
      expect(
        semanticsNode,
        matchesSemantics(
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          label: '1W range',
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    // Prove meaningfulness: verify that the unselected button also has a
    // tap action — confirming the forwarded onTap is what produces hasTapAction.
    // ExcludeSemantics suppresses the GestureDetector child's tap, so
    // hasTapAction can ONLY be present if the outer Semantics.onTap is wired.
    testWidgets('unselected range button also has tap action (onTap forward is wired)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSelector(tester);

      // 1M is not selected — if onTap forward were missing the node would
      // not carry hasTapAction (ExcludeSemantics suppresses the child's tap).
      final semanticsNode = tester.getSemantics(find.bySemanticsLabel('1M range'));
      expect(
        semanticsNode,
        matchesSemantics(
          isButton: true,
          isSelected: false,
          hasSelectedState: true,
          label: '1M range',
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
