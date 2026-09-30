import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../domain/favorite_pair.dart';
import '../domain/favorites_reorder_index.dart';
import 'favorite_hero_card.dart';
import 'favorite_pair_row.dart';
import 'favorites_empty_slot.dart';
import 'favorites_section_header.dart';
import 'favorites_upgrade_row.dart';

/// One reorderable list: the hero card (index 0) plus the plain rows after
/// it. Dropping a row at the top promotes it to hero. The "MORE PAIRS · N OF
/// M" label sits between them as an inert (non-draggable) child, so
/// [_pairIndex] translates ReorderableListView's raw child index back to a
/// pair index before calling [onReorder].
class FavoritesList extends StatelessWidget {
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

  static const Key _sectionHeaderKey = ValueKey<String>(
    'favorites_section_header',
  );

  @override
  Widget build(BuildContext context) {
    final visiblePairs = pairs.take(visibleLimit).toList();
    final hiddenCount = pairs.length - visibleLimit;
    final isAtLimit = visiblePairs.length >= effectiveLimit;
    final hasHeader = visiblePairs.length > 1;
    final showUpgradeRow = hiddenCount > 0 || isAtLimit;

    return Column(
      children: <Widget>[
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) => onReorder(
            favoritesChildToPairIndex(oldIndex, hasHeader: hasHeader),
            favoritesChildToPairIndex(newIndex, hasHeader: hasHeader),
          ),
          children: <Widget>[
            FavoriteHeroCard(
              key: ValueKey<String>(visiblePairs[0].toKey()),
              pair: visiblePairs[0],
              snapshot: snapshot,
              onOpen: () => onOpen(visiblePairs[0]),
              onRemove: () => onRemove(visiblePairs[0]),
            ),
            if (hasHeader)
              Padding(
                key: _sectionHeaderKey,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space3),
                child: FavoritesSectionHeader(
                  visibleCount: visiblePairs.length,
                  effectiveLimit: effectiveLimit,
                ),
              ),
            for (var index = 1; index < visiblePairs.length; index++)
              FavoritePairRow(
                key: ValueKey<String>(visiblePairs[index].toKey()),
                pair: visiblePairs[index],
                index: index,
                snapshot: snapshot,
                isLast: index == visiblePairs.length - 1,
                onOpen: () => onOpen(visiblePairs[index]),
                onRemove: () => onRemove(visiblePairs[index]),
                onMoveUp: () => onReorder(index, index - 1),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.space4),
        if (showUpgradeRow)
          FavoritesUpgradeRow(
            hiddenCount: hiddenCount,
            canOfferBoost: canOfferBoost,
            hasFavoritesPro: hasFavoritesPro,
            onWatchAd: onWatchAd,
            onBuyPro: onBuyPro,
          )
        else
          FavoritesEmptySlot(onAdd: onAdd),
      ],
    );
  }
}
