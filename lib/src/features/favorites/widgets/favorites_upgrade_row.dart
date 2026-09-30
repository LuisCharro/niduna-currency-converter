import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/clamped_text_scale.dart';
import 'favorites_upgrade_pill.dart';

/// One quiet row that replaces the old boxed limit/hidden notes: a lock icon
/// + lead line, plus up to two small outline pills. The hidden-pairs variant
/// (some stored pairs are beyond the visible slice) keeps its existing
/// copy/logic, just restyled to match; the plain at-limit variant uses the
/// shorter "Want more pairs?" copy.
class FavoritesUpgradeRow extends StatelessWidget {
  const FavoritesUpgradeRow({
    required this.hiddenCount,
    required this.canOfferBoost,
    required this.hasFavoritesPro,
    required this.onWatchAd,
    required this.onBuyPro,
    super.key,
  });

  final int hiddenCount;
  final bool canOfferBoost;
  final bool hasFavoritesPro;
  final VoidCallback onWatchAd;
  final VoidCallback onBuyPro;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    final isHidden = hiddenCount > 0;
    final leadText = isHidden
        ? loc.favoritesPairsHidden(hiddenCount)
        : loc.favoritesWantMorePairs;

    return ClampedTextScale(
      maxScaleFactor: 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lock_outline_rounded, size: 15, color: colors.primary),
              const SizedBox(width: AppTheme.space2),
              Expanded(
                child: Text(
                  leadText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.supportingTextStyle(context),
                ),
              ),
            ],
          ),
          if (canOfferBoost || !hasFavoritesPro) ...<Widget>[
            const SizedBox(height: AppTheme.space2),
            Wrap(
              spacing: AppTheme.space2,
              runSpacing: AppTheme.space2,
              children: <Widget>[
                if (canOfferBoost)
                  FavoritesUpgradePill(
                    icon: Icons.play_circle_outline_rounded,
                    label: isHidden
                        ? loc.favoritesWatchAdToShow
                        : loc.favoritesWatchAdPillLabel,
                    onTap: onWatchAd,
                  ),
                if (!hasFavoritesPro)
                  FavoritesUpgradePill(
                    icon: Icons.diamond_outlined,
                    label: isHidden
                        ? loc.favoritesUnlockForever
                        : loc.favoritesProPillLabel,
                    onTap: onBuyPro,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
