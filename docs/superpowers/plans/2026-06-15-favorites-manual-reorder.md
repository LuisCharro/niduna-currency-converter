# Favorites Manual Drag-to-Reorder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Favorites usage-based auto-sort with a user-controlled manual order set via an always-visible drag handle, persisted locally.

**Architecture:** `FavoritesStore._pairs` (already the persisted insertion-order list) becomes the single source of display order. The Favorites tab renders the visible slice in a nested `ReorderableListView` with a per-row `☰` handle; `onReorder` calls `FavoritesStore.reorder`, which mutates and persists `_pairs`. All usage-tracking code (`FavoriteUsageTracker`, `sortedPairs`, `recordUsage`/`recordPairUsage`, `onPairOpened`, and the `useCount`/`lastUsedAt` fields) is removed.

**Tech Stack:** Flutter (Material `ReorderableListView`, `ReorderableDragStartListener`), `ChangeNotifier`, SharedPreferences. No new dependencies.

**Spec:** `docs/superpowers/specs/2026-06-15-favorites-manual-reorder-design.md`

**Commit sequencing rule:** Each task leaves the build compiling and the full suite green. Task 1 is additive; Task 2 switches the UI to manual order (usage code still present but unused); Task 3 removes the now-dead usage code and its obsolete tests.

**Pre-flight (run once before Task 1):**

```bash
cd /Users/luis/Niduna/apps/currency-converter
git checkout main && git pull --ff-only 2>/dev/null || true
git checkout -b feat/favorites-manual-reorder
```

---

## Task 1: Add `FavoritesStore.reorder` (data layer, additive)

**Files:**
- Modify: `lib/src/features/favorites/data/favorites_store.dart`
- Test: `test/favorites_test.dart`

- [ ] **Step 1: Write the failing test**

Add this group to `test/favorites_test.dart` (place it after the existing `FavoritesStore` group, before the `sortedPairs` group — the `sortedPairs` group is deleted in Task 3):

```dart
  group('reorder (manual order)', () {
    late SharedPreferences prefs;
    late FavoritesStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      store = FavoritesStore(prefs);
    });

    tearDown(() => store.dispose());

    test('moves an item from first to last', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');

      await store.reorder(0, 3); // ReorderableListView passes end+1

      expect(store.pairs.map((p) => p.quote).toList(),
          <String>['GBP', 'JPY', 'EUR']);
    });

    test('moves an item from last to first', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');

      await store.reorder(2, 0);

      expect(store.pairs.map((p) => p.quote).toList(),
          <String>['JPY', 'EUR', 'GBP']);
    });

    test('persists the new order across a reload', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.reorder(1, 0);

      final reloaded = FavoritesStore(prefs);
      expect(reloaded.pairs.map((p) => p.quote).toList(),
          <String>['GBP', 'EUR']);
      reloaded.dispose();
    });

    test('out-of-range oldIndex is a no-op', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');

      await store.reorder(5, 0);

      expect(store.pairs.map((p) => p.quote).toList(),
          <String>['EUR', 'GBP']);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/favorites_test.dart --plain-name "reorder (manual order)"`
Expected: FAIL — `The method 'reorder' isn't defined for the type 'FavoritesStore'`.

- [ ] **Step 3: Implement `reorder`**

In `lib/src/features/favorites/data/favorites_store.dart`, add this method (place it right after the `remove` method):

```dart
  /// Moves the favorite at [oldIndex] to [newIndex] and persists the new order.
  /// [newIndex] follows the ReorderableListView convention (it can be
  /// `length`, meaning "after the last item").
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _pairs.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > _pairs.length - 1) target = _pairs.length - 1;
    if (target == oldIndex) return;
    final next = <FavoritePair>[..._pairs];
    final moved = next.removeAt(oldIndex);
    next.insert(target, moved);
    _pairs = next;
    _save();
    notifyListeners();
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/favorites_test.dart --plain-name "reorder (manual order)"`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/favorites/data/favorites_store.dart test/favorites_test.dart
git commit -m "feat(favorites): add FavoritesStore.reorder for manual ordering"
```

---

## Task 2: Drag-handle UI + switch Favorites tab to manual order

**Files:**
- Modify: `lib/src/features/favorites/widgets/favorite_pair_row.dart` (add `index` + `☰` handle)
- Modify: `lib/src/features/favorites/widgets/favorites_list.dart` (ReorderableListView + `onReorder`)
- Modify: `lib/src/features/favorites/widgets/favorites_tab_body.dart` (thread `onReorder`)
- Modify: `lib/src/features/favorites/favorites_screen.dart` (use `pairs`, wire `store.reorder`, drop `recordUsage`)
- Test: `test/favorites_reorder_widget_test.dart` (new)

- [ ] **Step 1: Write the failing widget test**

Create `test/favorites_reorder_widget_test.dart`:

```dart
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
        onReorder: (_, __) {},
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
        onReorder: (_, __) {},
        onAdd: () {},
        onWatchAd: () {},
        onBuyPro: () {},
      ),
    ));

    expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/favorites_reorder_widget_test.dart`
Expected: FAIL — `FavoritesList` has no `onReorder` parameter (compile error) and/or no `drag_handle` icon found.

- [ ] **Step 3: Add `index` + drag handle to `FavoritePairRow`**

In `lib/src/features/favorites/widgets/favorite_pair_row.dart`:

a) Add an `index` field to the constructor and class:

```dart
  const FavoritePairRow({
    required this.pair,
    required this.index,
    required this.snapshot,
    required this.showDivider,
    required this.onOpen,
    required this.onRemove,
    super.key,
  });

  final FavoritePair pair;
  final int index;
  final LatestRatesSnapshot? snapshot;
  final bool showDivider;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
```

b) Add the drag handle into the top `Row` (the one holding `FavoritePairIdentity` + the remove `IconButton`). Insert it just before the closing `],` of that Row's children, after the remove-button `Semantics(...)` widget:

```dart
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.drag_handle,
                            size: 22,
                            color: colors.muted,
                            semanticLabel: 'Reorder',
                          ),
                        ),
                      ),
```

- [ ] **Step 4: Convert `FavoritesList` to a `ReorderableListView`**

Replace the body of `build` in `lib/src/features/favorites/widgets/favorites_list.dart`. Add an `onReorder` field to the constructor first:

```dart
  const FavoritesList({
    required this.pairs,
    required this.effectiveLimit,
    required this.visibleLimit,
    required this.hasFavoritesPro,
    required this.canOfferBoost,
    required this.snapshot,
    required this.onOpen,
    required this.onRemove,
    required this.onReorder,
    required this.onAdd,
    required this.onWatchAd,
    required this.onBuyPro,
    super.key,
  });

  final List<FavoritePair> pairs;
  final int effectiveLimit;
  final int visibleLimit;
  final bool hasFavoritesPro;
  final bool canOfferBoost;
  final LatestRatesSnapshot? snapshot;
  final ValueChanged<FavoritePair> onOpen;
  final ValueChanged<FavoritePair> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;
  final VoidCallback onWatchAd;
  final VoidCallback onBuyPro;
```

Then the `build` method:

```dart
  @override
  Widget build(BuildContext context) {
    final visiblePairs = pairs.take(visibleLimit).toList();
    final hiddenCount = pairs.length - visibleLimit;
    final isAtLimit = visiblePairs.length >= effectiveLimit;

    return Column(
      children: <Widget>[
        FavoritesListHeader(
          count: pairs.length,
          maxLimit: effectiveLimit,
          visibleCount: visiblePairs.length,
          isAtLimit: isAtLimit && hiddenCount == 0,
          snapshot: snapshot,
          onAdd: onAdd,
        ),
        const SizedBox(height: AppTheme.space3),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: onReorder,
          children: <Widget>[
            for (var index = 0; index < visiblePairs.length; index++)
              FavoritePairRow(
                key: ValueKey<String>(visiblePairs[index].toKey()),
                pair: visiblePairs[index],
                index: index,
                snapshot: snapshot,
                showDivider: index != visiblePairs.length - 1 || hiddenCount > 0,
                onOpen: () => onOpen(visiblePairs[index]),
                onRemove: () => onRemove(visiblePairs[index]),
              ),
          ],
        ),
        if (hiddenCount > 0) ...<Widget>[
          const SizedBox(height: AppTheme.space5),
          FavoritesHiddenNote(
            hiddenCount: hiddenCount,
            canOfferBoost: canOfferBoost,
            onWatchAd: onWatchAd,
            onBuyPro: onBuyPro,
          ),
        ],
        if (isAtLimit && hiddenCount == 0) ...<Widget>[
          const SizedBox(height: AppTheme.space5),
          FavoritesLimitNote(
            canOfferBoost: canOfferBoost,
            onWatchAd: onWatchAd,
            onBuyPro: onBuyPro,
          ),
        ],
      ],
    );
  }
```

- [ ] **Step 5: Thread `onReorder` through `FavoritesTabBody`**

In `lib/src/features/favorites/widgets/favorites_tab_body.dart`, add the field to the constructor and class (mirror the existing `onRemove` declarations), and pass it to `FavoritesList`:

Constructor: add `required this.onReorder,` after `required this.onRemove,`.
Field: add `final void Function(int oldIndex, int newIndex) onReorder;` after `final ValueChanged<FavoritePair> onRemove;`.
In the `FavoritesList(...)` call, add `onReorder: onReorder,` after `onRemove: onRemove,`.

- [ ] **Step 6: Wire the store + use manual order in `FavoritesScreen`**

In `lib/src/features/favorites/favorites_screen.dart`:

a) Change `pairs: favoritesStore.sortedPairs,` to `pairs: favoritesStore.pairs,`.

b) Add `onReorder: favoritesStore.reorder,` immediately after the `onRemove: controller.removeFavoritePair,` line in the `FavoritesTabBody(...)` call.

c) In `_openPair`, delete the line `favoritesStore.recordUsage(pair.base, pair.quote);` so the method becomes:

```dart
  Future<void> _openPair(FavoritePair pair) async {
    await controller.openFavoritePair(pair);
    onNavigateToConvert(pair.base, pair.quote);
  }
```

- [ ] **Step 7: Fix the existing `FavoritePairRow` caller in tests**

Adding `required this.index` breaks the existing row test. In `test/favorites_trend_row_test.dart`, add `index: 0,` to the `FavoritePairRow(...)` call inside `pumpRow` (after `pair: const FavoritePair(...)`).

- [ ] **Step 8: Run the widget tests + analyze**

Run: `flutter test test/favorites_reorder_widget_test.dart test/favorites_trend_row_test.dart && flutter analyze lib/src/features/favorites`
Expected: PASS + `No issues found!`.

- [ ] **Step 9: Run the full suite (sortedPairs/usage tests still pass here)**

Run: `flutter test`
Expected: all pass. (Usage code is still present and wired, just unused by the tab.)

- [ ] **Step 10: Commit**

```bash
git add lib/src/features/favorites test/favorites_reorder_widget_test.dart test/favorites_trend_row_test.dart
git commit -m "feat(favorites): manual drag-to-reorder with always-visible handle"
```

---

## Task 3: Remove the dead usage-tracking code and obsolete tests

**Files:**
- Delete: `lib/src/features/favorites/data/favorite_usage_tracker.dart`
- Delete: `test/favorite_usage_tracker_test.dart`
- Modify: `lib/src/features/favorites/data/favorites_store.dart` (drop mixin + `sortedPairs`)
- Modify: `lib/src/features/favorites/domain/favorite_pair.dart` (drop `useCount`/`lastUsedAt`/`copyWith`)
- Modify: `lib/src/features/convert/presentation/convert_controller.dart` (drop `recordPairUsage`)
- Modify: `lib/src/features/convert/convert_screen.dart` (drop `onPairOpened`)
- Modify: `lib/src/features/convert/widgets/convert_content.dart` (drop `onPairOpened`)
- Modify: `lib/src/features/convert/widgets/visible_rates_list.dart` (drop `onPairOpened`)
- Modify: `lib/src/features/convert/presentation/convert_state_helpers.dart` (use `pairs`, not `sortedPairs`)
- Modify: `test/favorites_test.dart` (remove `sortedPairs` group)
- Modify: `test/convert_real_rates_test.dart` (remove `recordPairUsage` test)
- Modify: `test/ui_redesign_widget_test.dart` (remove `onPairOpened` wiring)

- [ ] **Step 1: Delete the usage tracker + its test**

```bash
git rm lib/src/features/favorites/data/favorite_usage_tracker.dart \
       test/favorite_usage_tracker_test.dart
```

- [ ] **Step 2: Strip usage code from `FavoritesStore`**

In `lib/src/features/favorites/data/favorites_store.dart`:
- Remove the import `import 'favorite_usage_tracker.dart';`.
- Change the class declaration from `class FavoritesStore extends ChangeNotifier with FavoriteUsageTracker {` to `class FavoritesStore extends ChangeNotifier {`.
- Delete the entire `sortedPairs` getter (the `List<FavoritePair> get sortedPairs { ... }` block).
- Delete the public `prefs` getter entirely (the two lines `@override\n  SharedPreferences get prefs => _prefs;`). It only existed to satisfy the now-removed mixin; all internal code already uses the private `_prefs` field. After this, `grep -n "[^_]prefs" lib/src/features/favorites/data/favorites_store.dart` should return nothing.

- [ ] **Step 3: Strip usage fields from `FavoritePair`**

Replace `lib/src/features/favorites/domain/favorite_pair.dart` with:

```dart
class FavoritePair {
  const FavoritePair({
    required this.base,
    required this.quote,
  });

  final String base;
  final String quote;

  factory FavoritePair.fromKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) {
      throw FormatException('Invalid favorite key: $key');
    }
    return FavoritePair(base: parts[0], quote: parts[1]);
  }

  String toKey() => '$base-$quote';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritePair && base == other.base && quote == other.quote;

  @override
  int get hashCode => Object.hash(base, quote);

  @override
  String toString() => '$base → $quote';
}
```

- [ ] **Step 4: Remove `recordPairUsage` from `ConvertController`**

In `lib/src/features/convert/presentation/convert_controller.dart`, delete the entire `recordPairUsage` method (the doc comment block at lines ~119-127 and the method body that calls `store.recordUsage(_base, quote)`).

- [ ] **Step 5: Remove the `onPairOpened` callback chain**

a) `lib/src/features/convert/convert_screen.dart`: delete the line `onPairOpened: controller.recordPairUsage,`.

b) `lib/src/features/convert/widgets/convert_content.dart`: delete `required this.onPairOpened,` (constructor), `final ValueChanged<String> onPairOpened;` (field), and `onPairOpened: widget.onPairOpened,` (the pass-down to `VisibleRatesList`).

c) `lib/src/features/convert/widgets/visible_rates_list.dart`: delete `this.onPairOpened,` (constructor), `final ValueChanged<String>? onPairOpened;` (field), and the line `widget.onPairOpened?.call(quote.code);` inside the `onPressed` callback (keep the rest of that callback — the `ConversionLensSheet.show(...)` call stays).

- [ ] **Step 6: Point the home-widget pipeline at the manual order**

In `lib/src/features/convert/presentation/convert_state_helpers.dart`, change `favoritesStore.sortedPairs` back to `favoritesStore.pairs` in the `favQuotes` assignment inside `pushHomeWidgetData`, and update the adjacent comment to read: `// Use the user's manual favorite order for the home widget rows.`

- [ ] **Step 7: Remove obsolete tests**

a) `test/favorites_test.dart`: delete the entire `group('sortedPairs (auto-sort by usage)', () { ... });` block.

b) `test/convert_real_rates_test.dart`: delete the entire `test('recordPairUsage tracks favorites and ignores non-favorites', () async { ... });` block.

c) `test/ui_redesign_widget_test.dart`: delete the line `onPairOpened: controller.recordPairUsage,`.

- [ ] **Step 8: Analyze to catch any missed reference**

Run: `flutter analyze`
Expected: `No issues found!`. If anything references `recordUsage`, `recordPairUsage`, `sortedPairs`, `useCount`, `lastUsedAt`, or `onPairOpened`, fix that reference (it is dead and should be removed).

- [ ] **Step 9: Run the full suite**

Run: `flutter test`
Expected: all pass (the removed tests are gone; the new `reorder` + widget tests remain).

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "refactor(favorites): remove usage auto-sort superseded by manual reorder"
```

---

## Task 4: Full verification gate + runtime check

**Files:** none (verification only)

- [ ] **Step 1: Run the project check script**

Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.

- [ ] **Step 2: Build, seed, and launch on the iOS simulator**

```bash
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 SEED_DAYS=90 \
  ./.devtools/run_seeded_ios_app.sh
```
Expected: app builds, seeds, and launches. (Seeded run creates starter favorites USD-EUR/USD-GBP/USD-BTC.)

- [ ] **Step 3: Screenshot the Favorites tab and confirm the handle**

Navigate to the Favorites tab in the simulator, then:

```bash
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 MAX_DIM=1200 \
  ./.devtools/sim_screenshot.sh favorites-reorder
```
Read the PNG under `.tmp/screens/ios/` and confirm: each favorite row shows a `☰` handle on the right; tap-to-open and the remove (×) button are still present.

- [ ] **Step 4: Confirm order persists**

Reorder a pair by dragging its handle, fully close the app (`xcrun simctl terminate 87FB7A6A-58E4-4F45-A44E-EC071B06BC04 com.niduna.currencyConverter`), relaunch (`xcrun simctl launch 87FB7A6A-58E4-4F45-A44E-EC071B06BC04 com.niduna.currencyConverter`), and confirm the new order survived. (Verify the flow visually — do not script blind coordinate taps.)

- [ ] **Step 5: Update PLAN.md feature table**

In `PLAN.md`, find the `Auto-sort favorites by usage` / favorites-related rows in the feature table and replace any auto-sort wording with: `Favorites manual reorder | DONE | Drag handle on each row; order persisted. Replaced usage auto-sort.` Remove now-inaccurate references to usage-based ordering.

- [ ] **Step 6: Commit the docs update**

```bash
git add PLAN.md
git commit -m "docs(plan): record favorites manual-reorder replacing usage auto-sort"
```

- [ ] **Step 7: Finish the branch**

Use the `superpowers:finishing-a-development-branch` skill to decide merge vs PR.

---

## Notes for the implementer

- **Index alignment:** the Favorites tab renders only `pairs.take(visibleLimit)` — the *prefix* of `_pairs`. So `ReorderableListView` indices map 1:1 onto `_pairs` indices, and `store.reorder(oldIndex, newIndex)` is correct without translation. Hidden pairs (beyond `visibleLimit`) are not rendered and therefore not draggable; this is the documented, accepted limitation.
- **Nested scrolling:** the `ReorderableListView` is `shrinkWrap: true` + `NeverScrollableScrollPhysics` because it lives inside the existing outer `ListView` (wrapped by `NidunaRefreshIndicator`). If drag-autoscroll misbehaves on long lists, the fallback is to make the favorites list itself the single `ReorderableListView` with a `header:` — but the list is capped small, so this is unlikely to be needed.
- **No persistence migration:** `useCount`/`lastUsedAt` were runtime-only (never in `toKey()`), and equality is base+quote, so dropping them does not change the stored `favorite_pairs` format.
