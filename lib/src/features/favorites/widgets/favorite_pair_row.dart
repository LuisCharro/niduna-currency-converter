import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/divider_list_row.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../domain/favorite_pair.dart';
import '../domain/favorite_pair_rate.dart';
import 'favorite_pair_identity.dart';
import 'favorite_rate_text.dart';

class FavoritePairRow extends StatelessWidget {
  const FavoritePairRow({
    required this.pair,
    required this.snapshot,
    required this.showDivider,
    required this.onOpen,
    required this.onRemove,
    super.key,
  });

  final FavoritePair pair;
  final LatestRatesSnapshot? snapshot;
  final bool showDivider;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    final rate = rateForFavoritePair(pair: pair, snapshot: snapshot);
    return DividerListRow(
      onTap: onOpen,
      showDivider: showDivider,
      leadingAccent: colors.primary.withValues(alpha: .18),
      trailing: IconButton(
        onPressed: onRemove,
        tooltip: loc.removeFavoriteTooltip,
        icon: Icon(Icons.close_rounded, size: 21, color: colors.subtle),
      ),
      child: Semantics(
        button: true,
        label: loc.openFavoriteTooltip,
        child: Row(
          children: <Widget>[
            Expanded(child: FavoritePairIdentity(pair: pair)),
            const SizedBox(width: AppTheme.space3),
            FavoriteRateText(rate: rate),
          ],
        ),
      ),
    );
  }
}
