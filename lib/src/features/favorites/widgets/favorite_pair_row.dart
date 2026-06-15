import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../../convert/models/trend.dart';
import '../../convert/widgets/trend_badge.dart';
import '../domain/favorite_pair.dart';
import '../domain/favorite_pair_rate.dart';
import 'favorite_pair_identity.dart';
import 'favorite_rate_text.dart';

class FavoritePairRow extends StatelessWidget {
  const FavoritePairRow({
    required this.pair,
    required this.index,
    required this.snapshot,
    required this.showDivider,
    required this.onOpen,
    required this.onRemove,
    super.key,
  });

  final FavoritePair pair;
  final int index;
  final LatestRatesSnapshot? snapshot;
  final bool showDivider;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    final rate = rateForFavoritePair(pair: pair, snapshot: snapshot);
    final previousRate =
        previousRateForFavoritePair(pair: pair, snapshot: snapshot);
    final trend = trendDirectionFor(rate, previousRate);
    final changePercent = changePercentFor(rate, previousRate);
    final showTrend = shouldShowTrend(trend, changePercent);
    final pairLabel = '${pair.base} → ${pair.quote}';
    final directRateLine = _directRateLine(rate);
    return Padding(
      padding: EdgeInsets.only(bottom: showDivider ? AppTheme.space3 : 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onOpen();
          },
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: colors.border.withValues(alpha: .18)),
              boxShadow: AppTheme.subtleShadowFor(context),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      FavoritePairIdentity(pair: pair),
                      const Spacer(),
                      Semantics(
                        button: true,
                        label: loc.removeFavoriteTooltip,
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            onRemove();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.subtle,
                          ),
                          tooltip: loc.removeFavoriteTooltip,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.drag_handle,
                            size: 22,
                            color: colors.muted,
                            semanticLabel: loc.reorderFavoriteTooltip,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          pairLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.settingsTileTitleStyle(context).copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (showTrend) ...<Widget>[
                        TrendBadge(trend: trend!, changePercent: changePercent),
                        const SizedBox(width: 8),
                      ],
                      FavoriteRateText(rate: rate),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          directRateLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.supportingTextStyle(context).copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _directRateLine(double? rate) {
    if (rate == null) return '1 ${pair.base} = — ${pair.quote}';
    return '1 ${pair.base} = ${_formatRate(rate)} ${pair.quote}';
  }

  String _formatRate(double value) {
    final abs = value.abs();
    final decimals = abs >= 100
        ? 2
        : abs >= .1
        ? 4
        : 6;
    return intl.NumberFormat.decimalPatternDigits(
      decimalDigits: decimals,
    ).format(value);
  }
}
