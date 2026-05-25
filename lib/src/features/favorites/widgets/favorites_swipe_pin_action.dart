import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class FavoritesSwipePinAction extends StatelessWidget {
  const FavoritesSwipePinAction({required this.colors, super.key});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: colors.containerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.star_rounded, size: 18, color: colors.primary),
          const SizedBox(height: 3),
          Text(
            l10n(context).favoriteActionPin,
            style: AppTheme.caption.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }
}
