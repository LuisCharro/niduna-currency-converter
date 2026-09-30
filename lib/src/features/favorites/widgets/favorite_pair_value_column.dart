import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../convert/models/trend_direction.dart';
import 'favorite_rate_text.dart';

/// The green value pill + a plain trend text underneath, used by
/// [FavoritePairRow]. Unlike the hero's [TrendBadge] pill, the row's trend is
/// plain small text ("↑ 0.08%") so the value column stays short enough to
/// fit the row's fixed height, including at a clamped 1.3x text scale.
class FavoritePairValueColumn extends StatelessWidget {
  const FavoritePairValueColumn({
    required this.rate,
    required this.trend,
    required this.changePercent,
    super.key,
  });

  final double? rate;
  final TrendDirection? trend;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        FavoriteRateText(rate: rate),
        if (trend != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            _trendLabel(trend!, changePercent),
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _trendColor(context, trend!),
            ),
          ),
        ],
      ],
    );
  }

  String _trendLabel(TrendDirection trend, double? changePercent) {
    final glyph = switch (trend) {
      TrendDirection.up => '↑',
      TrendDirection.down => '↓',
      TrendDirection.flat => '',
    };
    final percent = changePercent == null
        ? ''
        : ' ${changePercent.abs().toStringAsFixed(2)}%';
    return '$glyph$percent';
  }

  Color _trendColor(BuildContext context, TrendDirection trend) {
    final colors = AppColors.of(context);
    return switch (trend) {
      TrendDirection.up => colors.trendUp,
      TrendDirection.down => colors.trendDown,
      TrendDirection.flat => colors.muted,
    };
  }
}
