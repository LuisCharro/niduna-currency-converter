import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/favorite_pair.dart';

/// "BASE → QUOTE" + the reverse-rate supporting line (omitted when the rate
/// is unavailable), used by [FavoritePairRow].
class FavoritePairTitleColumn extends StatelessWidget {
  const FavoritePairTitleColumn({
    required this.pair,
    required this.reverseLine,
    super.key,
  });

  final FavoritePair pair;
  final String? reverseLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '${pair.base} → ${pair.quote}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.settingsTileTitleStyle(
            context,
          ).copyWith(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        if (reverseLine != null) ...<Widget>[
          const SizedBox(height: 3),
          Text(
            reverseLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.supportingTextStyle(
              context,
            ).copyWith(fontSize: 12.5),
          ),
        ],
      ],
    );
  }
}
