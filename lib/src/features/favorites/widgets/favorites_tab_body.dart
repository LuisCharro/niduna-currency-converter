import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/niduna_refresh_indicator.dart';
import '../../../shared/widgets/screen_title.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../domain/favorite_pair.dart';
import 'favorites_empty_state.dart';
import 'favorites_list.dart';

class FavoritesTabBody extends StatelessWidget {
  const FavoritesTabBody({
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
    this.onRefresh,
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
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: AppTheme.pageInsets.copyWith(
        top: AppTheme.space6,
        bottom: AppTheme.space4,
      ),
      children: <Widget>[
        ScreenTitle(l10n(context).tabFavorites),
        const SizedBox(height: AppTheme.space4),
        if (pairs.isEmpty)
          FavoritesEmptyState(onAdd: onAdd)
        else
          FavoritesList(
            pairs: pairs,
            effectiveLimit: effectiveLimit,
            visibleLimit: visibleLimit,
            hasFavoritesPro: hasFavoritesPro,
            canOfferBoost: canOfferBoost,
            snapshot: snapshot,
            onOpen: onOpen,
            onRemove: onRemove,
            onAdd: onAdd,
            onWatchAd: onWatchAd,
            onBuyPro: onBuyPro,
          ),
      ],
    );

    if (onRefresh == null) return list;
    return NidunaRefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
