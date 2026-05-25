import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class FavoritesLimitNote extends StatelessWidget {
  const FavoritesLimitNote({
    required this.canOfferBoost,
    required this.onWatchAd,
    required this.onBuyPro,
    super.key,
  });

  final bool canOfferBoost;
  final VoidCallback onWatchAd;
  final VoidCallback onBuyPro;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.lock_outline_rounded, size: 16, color: colors.primary),
            const SizedBox(width: AppTheme.space2),
            Expanded(
              child: Text(
                l10n(context).favoritesLimitMessage,
                style: AppTheme.supportingTextStyle(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space3),
        if (canOfferBoost) ...<Widget>[
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.tonal(
              onPressed: onWatchAd,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.play_circle_outline, size: 16),
                  const SizedBox(width: 8),
                  Text(l10n(context).watchAdToAddMore),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space2),
        ],
        SizedBox(
          width: double.infinity,
          height: 40,
          child: FilledButton(
            onPressed: onBuyPro,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.diamond_outlined, size: 16),
                const SizedBox(width: 8),
                Text(l10n(context).favoritesUnlockForever),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
