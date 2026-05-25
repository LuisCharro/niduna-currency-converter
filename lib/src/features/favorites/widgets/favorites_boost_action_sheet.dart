import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';

class FavoritesBoostActionSheet extends StatelessWidget {
  const FavoritesBoostActionSheet({
    required this.storedCount,
    required this.freeLimit,
    required this.canWatchAd,
    required this.onWatchAd,
    required this.onBuyForever,
    super.key,
  });

  final int storedCount;
  final int freeLimit;
  final bool canWatchAd;
  final VoidCallback onWatchAd;
  final VoidCallback onBuyForever;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.lock_outline,
              size: 40,
              color: AppColors.of(context).muted,
            ),
            const SizedBox(height: 12),
            Text(
              loc.favoritesLimitReached,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.of(context).text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loc.favoritesLimitActionSubtitle(storedCount, freeLimit),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.of(context).muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (canWatchAd) ...<Widget>[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.tonal(
                  onPressed: onWatchAd,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.play_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(loc.watchAdToAddMore),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: onBuyForever,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.diamond_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(loc.favoritesUnlockForever),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                loc.btnCancel,
                style: TextStyle(color: AppColors.of(context).subtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
