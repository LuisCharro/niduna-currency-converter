import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/favorite_pair_rate.dart';

/// The big leaf-green rate + the reverse-rate supporting line (omitted when
/// the rate is unavailable), middle of [FavoriteHeroCard].
class FavoriteHeroRateBlock extends StatelessWidget {
  const FavoriteHeroRateBlock({
    required this.rate,
    required this.reverseLine,
    this.compact = false,
    super.key,
  });

  final double? rate;
  final String? reverseLine;

  /// Short-screen density mode (see [FavoriteHeroCard]): a smaller rate size
  /// so more rows stay visible below the hero on a short phone.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    var style = AppTheme.heroAmountFor(context).copyWith(color: colors.primary);
    if (compact) style = style.copyWith(fontSize: 36);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          rate == null ? '—' : formatFavoriteRate(rate!),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
        if (reverseLine != null) ...<Widget>[
          const SizedBox(height: AppTheme.space1),
          Text(
            reverseLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.supportingTextStyle(context),
          ),
        ],
      ],
    );
  }
}
