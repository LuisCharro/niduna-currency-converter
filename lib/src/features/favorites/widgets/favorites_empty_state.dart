import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pill_action.dart';
import 'favorites_swipe_hint.dart';

class FavoritesEmptyState extends StatelessWidget {
  const FavoritesEmptyState({required this.onAdd, super.key});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: colors.border.withValues(alpha: .12)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space7),
        child: Column(
          children: <Widget>[
            Icon(Icons.star_outline_rounded, size: 36, color: colors.primary),
            const SizedBox(height: AppTheme.space4),
            Text(
              loc.labelNoFavorites,
              style: AppTheme.settingsGroupTitleStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              loc.favoritesEmptyBody,
              style: AppTheme.supportingTextStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space5),
            const FavoritesSwipeHint(),
            const SizedBox(height: AppTheme.space5),
            PillAction(
              label: loc.favoritesOpenConvert,
              icon: Icons.arrow_forward_rounded,
              onTap: onAdd,
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}
