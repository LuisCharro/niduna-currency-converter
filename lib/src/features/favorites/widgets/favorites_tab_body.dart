import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/honest_fern_refresh_indicator.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../domain/favorite_pair.dart';
import 'favorites_empty_state.dart';
import 'favorites_header_row.dart';
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
    required this.onReorder,
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
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;
  final VoidCallback onWatchAd;
  final VoidCallback onBuyPro;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final insets = AppTheme.pageInsets.copyWith(
      top: AppTheme.space6,
      bottom: AppTheme.tabScrollBottomPadding(context),
    );
    final header = FavoritesHeaderRow(
      onRefresh: onRefresh == null ? null : () => onRefresh!(),
    );
    final list = pairs.isEmpty
        ? _emptyBody(context, insets, header)
        : ListView(
            padding: insets,
            children: <Widget>[
              header,
              const SizedBox(height: AppTheme.space4),
              FavoritesList(
                pairs: pairs,
                effectiveLimit: effectiveLimit,
                visibleLimit: visibleLimit,
                hasFavoritesPro: hasFavoritesPro,
                canOfferBoost: canOfferBoost,
                snapshot: snapshot,
                onOpen: onOpen,
                onRemove: onRemove,
                onReorder: onReorder,
                onAdd: onAdd,
                onWatchAd: onWatchAd,
                onBuyPro: onBuyPro,
              ),
            ],
          );

    if (onRefresh == null) return list;
    return HonestFernRefreshIndicator(onRefresh: onRefresh!, child: list);
  }

  /// Centers the empty state in the space left under the header instead of
  /// leaving a dead paper gap above the nav.
  Widget _emptyBody(BuildContext context, EdgeInsets insets, Widget header) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: insets.copyWith(bottom: 0),
          sliver: SliverToBoxAdapter(child: header),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: insets.copyWith(top: AppTheme.space4),
            child: Center(
              child: FavoritesEmptyState(
                effectiveLimit: effectiveLimit,
                onAdd: onAdd,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
