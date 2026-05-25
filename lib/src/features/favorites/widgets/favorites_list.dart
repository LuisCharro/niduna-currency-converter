import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../domain/favorite_pair.dart';
import 'favorite_pair_row.dart';
import 'favorites_limit_note.dart';
import 'favorites_list_header.dart';

class FavoritesList extends StatelessWidget {
  const FavoritesList({
    required this.pairs,
    required this.isFull,
    required this.snapshot,
    required this.onOpen,
    required this.onRemove,
    required this.onAdd,
    super.key,
  });

  final List<FavoritePair> pairs;
  final bool isFull;
  final LatestRatesSnapshot? snapshot;
  final ValueChanged<FavoritePair> onOpen;
  final ValueChanged<FavoritePair> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FavoritesListHeader(count: pairs.length, isFull: isFull, onAdd: onAdd),
        const SizedBox(height: AppTheme.space3),
        for (var index = 0; index < pairs.length; index++)
          FavoritePairRow(
            pair: pairs[index],
            snapshot: snapshot,
            showDivider: index != pairs.length - 1,
            onOpen: () => onOpen(pairs[index]),
            onRemove: () => onRemove(pairs[index]),
          ),
        if (isFull) ...<Widget>[
          const SizedBox(height: AppTheme.space5),
          const FavoritesLimitNote(),
        ],
      ],
    );
  }
}
