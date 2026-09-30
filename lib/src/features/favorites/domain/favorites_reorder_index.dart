/// Translates a raw child index from [FavoritesList]'s `ReorderableListView`
/// (hero + optional inert section-header slot + rows) back to a pair index
/// for `FavoritesStore.reorder`.
///
/// Children are `[hero, header?, row, row, ...]`. The header (present only
/// when there is more than one visible pair) sits at child index 1 and has
/// no drag listener, so it can never be `oldIndex`, but it can be the drop
/// target for `newIndex` (which means "the top of the rows", i.e. pair index
/// 1 — the same number, so no special-casing is needed there either).
int favoritesChildToPairIndex(int childIndex, {required bool hasHeader}) =>
    hasHeader && childIndex >= 2 ? childIndex - 1 : childIndex;
