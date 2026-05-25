import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../domain/favorite_pair.dart';
import 'favorite_pair_row.dart';
import 'favorites_hidden_note.dart';
import 'favorites_limit_note.dart';
import 'favorites_list_header.dart';

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
  final VoidCallback onAdd;
  final VoidCallback onWatchAd;
  final VoidCallback onBuyPro;

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
          onAdd: onAdd,
        ),
        const SizedBox(height: AppTheme.space3),
        for (var index = 0; index < visiblePairs.length; index++)
          FavoritePairRow(
            pair: visiblePairs[index],
            snapshot: snapshot,
            showDivider: index != visiblePairs.length - 1 || hiddenCount > 0,
            onOpen: () => onOpen(visiblePairs[index]),
            onRemove: () => onRemove(visiblePairs[index]),
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
}
