import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/overlapping_flag_pair.dart';
import '../../convert/models/trend_direction.dart';
import '../../convert/widgets/trend_badge.dart';
import '../domain/favorite_pair.dart';

/// Flags + "BASE → QUOTE" + trend pill, top row of [FavoriteHeroCard].
class FavoriteHeroTitleRow extends StatelessWidget {
  const FavoriteHeroTitleRow({
    required this.pair,
    required this.trend,
    required this.changePercent,
    super.key,
  });

  final FavoritePair pair;
  final TrendDirection? trend;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        OverlappingFlagPair(base: pair.base, quote: pair.quote, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${pair.base} → ${pair.quote}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.settingsGroupTitleStyle(context),
          ),
        ),
        if (trend != null)
          TrendBadge(trend: trend!, changePercent: changePercent),
      ],
    );
  }
}
