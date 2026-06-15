# Favorites — Manual Drag-to-Reorder (replaces usage auto-sort)

> **Status:** Design approved 2026-06-15. Ready for implementation plan.
> **Branch:** `main`
> **Supersedes:** usage-based auto-sort (`FavoritesStore.sortedPairs` + `FavoriteUsageTracker`).

---

## Goal

Let the user arrange their favorite pairs in a hand-picked order using an
always-visible drag handle (`☰`), with the order persisted locally. This
**replaces** the automatic usage-based sort entirely — what the user sets is
what they see, on both the Favorites tab and the home-screen widget.

## Why

The current Favorites tab auto-sorts by usage count (then last-used time) via
`FavoritesStore.sortedPairs`. Usage-based ordering is implicit and surprising —
rows shuffle as the user converts. A manual order is predictable and gives the
user direct control over which favorites occupy the limited visible slots (see
"Interaction with the free/Pro limit" below).

## Decisions (from brainstorming)

- **Sort behavior:** Replace auto-sort with manual ordering. No coexistence mode.
- **Drag affordance:** Always-visible `☰` handle on the right of each row; drag
  starts from the handle only. Tap-to-open and swipe-to-remove are unchanged.
- **Usage tracking:** Remove fully. It is the feature being superseded; leaving
  it produces tested-but-unused dead code.

## Non-goals

- No "edit mode" toggle or long-press-to-drag.
- No change to the add/remove flows, the free/Pro limit mechanic, or the
  rewarded-ad / Favorites Pro upsells.
- No reordering of the main Convert rates list (it stays a full multi-currency
  view; favorites there are only *marked*, not ordered).

---

## Data layer — `lib/src/features/favorites/data/favorites_store.dart`

`_pairs` is already the persisted insertion-order list (a `StringList` of pair
keys in SharedPreferences under `favorite_pairs`). It becomes the single source
of truth for display order.

- The UI switches from `sortedPairs` to `pairs`.
- Add:

  ```dart
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _pairs.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1; // ReorderableListView index convention
    if (target < 0) target = 0;
    if (target > _pairs.length - 1) target = _pairs.length - 1;
    final next = [..._pairs];
    final moved = next.removeAt(oldIndex);
    next.insert(target, moved);
    _pairs = next;
    _save();
    notifyListeners();
  }
  ```

- **Remove** the `sortedPairs` getter and the `with FavoriteUsageTracker` mixin
  usage. Delete `favorite_usage_tracker.dart`.

### `FavoritePair` — `lib/src/features/favorites/domain/favorite_pair.dart`

- Remove the `useCount` and `lastUsedAt` fields and any `copyWith` params that
  only existed to carry them. Keep `base`, `quote`, key (de)serialization, and
  equality unchanged so the persisted `favorite_pairs` format is untouched
  (no migration needed).

### Call-site removals

- `lib/src/features/favorites/favorites_screen.dart` — drop the
  `favoritesStore.recordUsage(...)` call in `_openPair`; feed `pairs` (not
  `sortedPairs`) to `FavoritesTabBody`.
- `lib/src/features/convert/presentation/convert_controller.dart` — remove
  `recordPairUsage(...)` and its call sites.
- `lib/src/features/convert/presentation/convert_state_helpers.dart` — the home
  widget pair selection uses `favoritesStore.pairs` (manual order). (Reverts the
  2026-06-15 `sortedPairs` change made earlier the same day.)

---

## UI layer

### `lib/src/features/favorites/widgets/favorites_list.dart`

Replace the `for`-loop of `FavoritePairRow`s with a `ReorderableListView`:

- `shrinkWrap: true`, `physics: const NeverScrollableScrollPhysics()` so it
  nests inside the existing outer `ListView` (and its `NidunaRefreshIndicator`
  pull-to-refresh) without a competing scroll view.
- `buildDefaultDragHandles: false` — we supply our own handle (below).
- `onReorder: (oldIndex, newIndex) => onReorder(oldIndex, newIndex)`, a new
  callback threaded `FavoritesList → FavoritesTabBody → FavoritesScreen →
  store.reorder`.
- Only the visible slice (`pairs.take(visibleLimit)`) is rendered, exactly as
  today. Reordering therefore operates on visible rows only; hidden rows are not
  draggable until a slot frees up. This is acceptable for a ≤ small list and is
  documented, not silently dropped.
- Header (`FavoritesListHeader`), hidden-note, and limit-note stay **outside**
  the reorderable region.
- Each child needs a stable `Key` (e.g. `ValueKey(pair.toKey())`).

### `lib/src/features/favorites/widgets/favorite_pair_row.dart`

- Add a trailing `☰` handle: `Icon(Icons.drag_handle)` wrapped in
  `ReorderableDragStartListener(index: index, child: ...)`. The row therefore
  needs its `index` passed in.
- Handle uses `AppColors.of(context).muted` so it adapts to dark mode; sized and
  padded to meet the touch-target guidance in the mobile UI skills.
- Existing tap (open) and swipe (remove) gestures are preserved; the drag is
  isolated to the handle so it does not compete with them.

---

## Testing

- **New:** `FavoritesStore.reorder` unit test — move first→last, last→first,
  no-op same index, out-of-range guard; assert order **and** persistence
  (reload a fresh store from the same prefs and confirm the new order).
- **New/updated:** a widget test that the Favorites list renders a drag handle
  per visible row and that an `onReorder` callback maps indices to
  `store.reorder` correctly.
- **Remove:** `favorite_usage_tracker_test.dart` and the
  `sortedPairs (auto-sort by usage)` group in `favorites_test.dart`; update
  `convert_real_rates_test.dart` to drop the `recordPairUsage`/usage-ranking
  assertions.
- `./scripts/check.sh` green (analyze + full suite) before completion.
- Runtime check on the iOS simulator (seeded data) per project workflow:
  confirm the handle renders, a drag reorders, and the order survives an app
  relaunch. (Per project guidance, verify the flow — not blind coordinate taps.)

---

## Risks & edge cases

- **Nested scroll views:** a shrinkWrap `ReorderableListView` inside the outer
  `ListView` can feel janky for long lists, but the favorites list is small
  (free ≈ 3, capped). If drag autoscroll misbehaves, fall back to making the
  favorites list itself the single `ReorderableListView` with a `header:`.
- **Hidden pairs:** can't be dragged while hidden behind the free/Pro gate.
  Documented limitation, not a defect.
- **Persisted format unchanged:** removing `useCount`/`lastUsedAt` must not
  alter the `favorite_pairs` key format — those fields were derived at runtime,
  not persisted, so there is no migration.

## Out of scope

- Edit-mode toggle, long-press drag, reordering hidden rows in place,
  reordering the Convert rates list.
