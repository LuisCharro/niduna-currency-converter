import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/clamped_text_scale.dart';
import '../../../shared/widgets/swipe_draggable_card.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../../convert/domain/rate_freshness.dart';
import '../../convert/models/trend.dart';
import '../domain/favorite_pair.dart';
import '../domain/favorite_pair_rate.dart';
import '../domain/favorite_reverse_rate.dart';
import 'favorite_hero_freshness_row.dart';
import 'favorite_hero_rate_block.dart';
import 'favorite_hero_title_row.dart';
import 'favorite_swipe_row.dart';

/// The first visible pair, shown as a hero card (mirrors Convert's amount
/// card): flags + pair name + trend up top, the big rate, the reverse-rate
/// line, then a freshness status line.
///
/// The card has no fixed height of its own — [FavoriteSwipeRow] sizes the
/// swipe stack to this content's natural height (see its sizing proxy), so
/// the card never reserves more vertical space than it needs on a taller
/// device. On short screens (`MediaQuery` height < 700, see `AmountPanel`'s
/// own `compact` mode in Convert) the card uses a smaller rate size and
/// tighter padding, both to look denser and to naturally end up shorter, so
/// at least a couple of rows stay visible below it above the ad shelf on a
/// 360×640 phone.
class FavoriteHeroCard extends StatelessWidget {
  const FavoriteHeroCard({
    required this.pair,
    required this.snapshot,
    required this.onOpen,
    required this.onRemove,
    super.key,
  });

  static const double _shortScreenThreshold = 700;

  final FavoritePair pair;
  final LatestRatesSnapshot? snapshot;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < _shortScreenThreshold;
    final rate = rateForFavoritePair(pair: pair, snapshot: snapshot);
    final previousRate = previousRateForFavoritePair(
      pair: pair,
      snapshot: snapshot,
    );
    final trend = trendDirectionFor(rate, previousRate);
    final changePercent = changePercentFor(rate, previousRate);
    final showTrend = shouldShowTrend(trend, changePercent);
    final freshness = _freshnessLabel();

    return FavoriteSwipeRow(
      pair: pair,
      index: 0,
      surface: SwipeCardSurface.card,
      onOpen: onOpen,
      onRemove: onRemove,
      onMoveUp: null,
      child: Padding(
        // Same top and bottom padding (a fixed height used to add slightly
        // less at the bottom, leaving an off-centre look now that the card
        // hugs its content instead of a fixed box).
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: compact ? 14 : 18,
        ),
        child: ClampedTextScale(
          maxScaleFactor: 1.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FavoriteHeroTitleRow(
                pair: pair,
                trend: showTrend ? trend : null,
                changePercent: changePercent,
              ),
              SizedBox(height: compact ? AppTheme.space2 : AppTheme.space3),
              FavoriteHeroRateBlock(
                rate: rate,
                reverseLine: favoriteReverseRateLine(pair: pair, rate: rate),
                compact: compact,
              ),
              if (freshness != null) ...<Widget>[
                SizedBox(height: compact ? AppTheme.space2 : AppTheme.space3),
                FavoriteHeroFreshnessRow(label: freshness),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _freshnessLabel() {
    final data = snapshot;
    if (data == null) return null;
    return RateFreshness.updatedLabel(
      rateDate: data.date,
      savedAt: data.savedAt,
    );
  }
}
