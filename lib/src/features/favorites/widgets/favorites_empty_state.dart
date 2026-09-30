import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/overlapping_flag_pair.dart';
import '../../../shared/widgets/pill_action.dart';
import 'dotted_border_box.dart';

class FavoritesEmptyState extends StatelessWidget {
  const FavoritesEmptyState({
    required this.effectiveLimit,
    required this.onAdd,
    super.key,
  });

  final int effectiveLimit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.containerHigh.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: .12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.space8,
          horizontal: AppTheme.space5,
        ),
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const OverlappingFlagPair(base: 'USD', quote: 'EUR', size: 40),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space6),
            Text(
              loc.labelNoFavorites,
              style: AppTheme.settingsGroupTitleStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              loc.favoritesEmptyBody(effectiveLimit),
              style: AppTheme.supportingTextStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space7),
            DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: AppTheme.subtleShadowFor(context),
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
              child: PillAction(
                label: loc.favoritesOpenConvert,
                icon: Icons.arrow_forward_rounded,
                onTap: onAdd,
                emphasized: true,
              ),
            ),
            const SizedBox(height: AppTheme.space6),
            DottedBorderBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space3,
                  vertical: AppTheme.space3,
                ),
                child: Row(
                  children: <Widget>[
                    const OverlappingFlagPair(
                      base: 'USD',
                      quote: 'EUR',
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.space3),
                    Expanded(
                      child: Text(
                        loc.favoritesFirstPairPreview,
                        style: AppTheme.supportingTextStyle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
