import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
              index: 1,
              snapshot: LatestRatesSnapshot(
                base: 'USD',
                date: DateTime(2026, 6, 15),
                savedAt: DateTime(2026, 6, 15, 9),
                rates: const <String, double>{'EUR': 0.9},
              ),
              onOpen: () {},
              onRemove: () {},
              onMoveUp: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('open row carries a tap action', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpRow(tester);
      // Addressed by key rather than "first InkWell": the (always-built, if
      // not yet revealed) swipe-to-remove action is also an InkWell earlier
      // in the tree.
      expect(
        tester.getSemantics(find.byKey(const Key('open_USD-EUR'))),
        matchesSemantics(
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });

    // The visible × and drag handle are gone (D1 redesign), so open/remove/
    // move-up are exposed as custom semantics actions instead.
    testWidgets('row exposes open, remove and move-up custom actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpRow(tester);
      final labels = _allCustomActionLabels(tester);
      expect(
        labels,
        containsAll(<String>[
          'Open pair in Convert',
          'Remove favorite',
          'Reorder favorite',
        ]),
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
              includesCrypto: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'selected 1W range button is a selected button with tap action',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpSelector(tester);

        // hasSelectedState is set by Flutter when selected: is provided.
        final semanticsNode = tester.getSemantics(
          find.bySemanticsLabel('1W range'),
        );
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
      },
    );

    // Prove meaningfulness: verify that the unselected button also has a
    // tap action — confirming the forwarded onTap is what produces hasTapAction.
    // ExcludeSemantics suppresses the GestureDetector child's tap, so
    // hasTapAction can ONLY be present if the outer Semantics.onTap is wired.
    testWidgets(
      'unselected range button also has tap action (onTap forward is wired)',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpSelector(tester);

        // 1M is not selected — if onTap forward were missing the node would
        // not carry hasTapAction (ExcludeSemantics suppresses the child's tap).
        final semanticsNode = tester.getSemantics(
          find.bySemanticsLabel('1M range'),
        );
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
      },
    );
  });
}

/// Walks the whole semantics tree collecting every custom action's label,
/// regardless of exactly which node Flutter merged [Semantics.customSemanticsActions]
/// into.
List<String> _allCustomActionLabels(WidgetTester tester) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    final ids = node.getSemanticsData().customSemanticsActionIds;
    if (ids != null) {
      for (final id in ids) {
        labels.add(CustomSemanticsAction.getAction(id)!.label ?? '');
      }
    }
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  // ignore: deprecated_member_use
  visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return labels;
}
