import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Freshness dot + "Rates from ..." label, bottom of [FavoriteHeroCard].
/// Purely informational (reuses the freshness label and status styling);
/// there is no info affordance here — a non-tappable icon that looks
/// tappable would be worse than none.
class FavoriteHeroFreshnessRow extends StatelessWidget {
  const FavoriteHeroFreshnessRow({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: colors.trendUp,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.caption.copyWith(
              color: colors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
