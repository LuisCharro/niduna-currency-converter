import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/clamped_text_scale.dart';
import '../../../shared/widgets/overlapping_flag_pair.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../../convert/models/trend.dart';
import '../domain/favorite_pair.dart';
import '../domain/favorite_pair_rate.dart';
import '../domain/favorite_reverse_rate.dart';
import 'favorite_pair_title_column.dart';
import 'favorite_pair_value_column.dart';
import 'favorite_swipe_row.dart';

/// A plain Convert-style rate row for pairs after the hero (index 1..n):
/// overlapping flags, "BASE → QUOTE" + reverse-rate supporting line, and the
/// green value pill with the trend underneath. No card/border/shadow (per
/// DESIGN.md) — rows sit flush on the page canvas, separated by a hairline
/// divider (omitted after the last row).
class FavoritePairRow extends StatelessWidget {
  const FavoritePairRow({
    required this.pair,
    required this.index,
    required this.snapshot,
    required this.onOpen,
    required this.onRemove,
    required this.onMoveUp,
    this.isLast = false,
    super.key,
  });

  // Tall enough for the title column (2 lines) or the value column (a value
  // pill + a trend line) at a clamped 1.3x text scale, plus row padding.
  static const double rowHeight = 92;

  final FavoritePair pair;
  final int index;
  final LatestRatesSnapshot? snapshot;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final rate = rateForFavoritePair(pair: pair, snapshot: snapshot);
    final previousRate = previousRateForFavoritePair(
      pair: pair,
      snapshot: snapshot,
    );
    final trend = trendDirectionFor(rate, previousRate);
    final changePercent = changePercentFor(rate, previousRate);
    final showTrend = shouldShowTrend(trend, changePercent);
    final colors = AppColors.of(context);

    return Column(
      children: <Widget>[
        FavoriteSwipeRow(
          pair: pair,
          index: index,
          height: rowHeight,
          onOpen: onOpen,
          onRemove: onRemove,
          onMoveUp: onMoveUp,
          child: Padding(
            // No extra horizontal inset (matches Convert's plain
            // CurrencyRateRow): the row is flush with the page/list padding
            // that already wraps the whole list, so it lines up with the
            // "MORE PAIRS" label and the hero card's outer edge, not indented
            // further than either.
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ClampedTextScale(
              maxScaleFactor: 1.3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  OverlappingFlagPair(base: pair.base, quote: pair.quote),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FavoritePairTitleColumn(
                      pair: pair,
                      reverseLine: favoriteReverseRateLine(
                        pair: pair,
                        rate: rate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Long crypto values ("0.00001202") must not squeeze the
                  // title into an ellipsis — cap the value column's width
                  // and shrink it (not the title) if it needs more. FittedBox
                  // needs bounded constraints on both axes (an unbounded
                  // maxHeight makes it compute a NaN scale), so cap the
                  // height too, to the row's available content height.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.40,
                      maxHeight: rowHeight - 20,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: FavoritePairValueColumn(
                        rate: rate,
                        trend: showTrend ? trend : null,
                        changePercent: changePercent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 62),
            child: Divider(
              color: colors.border.withValues(alpha: .20),
              height: .5,
            ),
          ),
      ],
    );
  }
}
