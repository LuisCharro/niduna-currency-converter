import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/favorite_pair.dart';

class FavoritePairIdentity extends StatelessWidget {
  const FavoritePairIdentity({required this.pair, super.key});

  final FavoritePair pair;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${pair.base} → ${pair.quote}',
          style: AppTheme.settingsTileTitleStyle(context),
        ),
        const SizedBox(height: AppTheme.space1),
        Text(
          loc.favoritesCachedRate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.supportingTextStyle(context),
        ),
      ],
    );
  }
}
