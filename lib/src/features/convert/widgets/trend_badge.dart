import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/trend_direction.dart';

class TrendBadge extends StatelessWidget {
  const TrendBadge({required this.trend, this.changePercent, super.key});

  final TrendDirection trend;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final IconData icon;
    final Color color;

    switch (trend) {
      case TrendDirection.up:
        icon = Icons.arrow_upward;
        color = colors.trendUp;
      case TrendDirection.down:
        icon = Icons.arrow_downward;
        color = colors.trendDown;
      case TrendDirection.flat:
        icon = Icons.remove;
        color = colors.muted.withValues(alpha: .6);
    }

    final label = changePercent != null
        ? '${changePercent!.abs().toStringAsFixed(2)}%'
        : null;

    // Render as a subtle tinted pill so the small arrow + percent read as one
    // legible unit instead of a tiny stray glyph. Tint is derived from the
    // trend colour, so it adapts to light/dark automatically.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: label != null ? 7 : 5, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
