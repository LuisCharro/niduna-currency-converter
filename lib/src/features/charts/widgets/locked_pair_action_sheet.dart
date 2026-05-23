import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class LockedPairActionSheet extends StatelessWidget {
  const LockedPairActionSheet({
    required this.canWatchAd,
    required this.onWatchAd,
    required this.onBuyForever,
    super.key,
  });

  final bool canWatchAd;
  final VoidCallback onWatchAd;
  final VoidCallback onBuyForever;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.lock_outline, size: 40, color: AppColors.of(context).muted),
            const SizedBox(height: 12),
            Text(
              pairLockedTitle(context),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.of(context).text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pairLockedSubtitle(context, canWatchAd),
              style: TextStyle(fontSize: 13, color: AppColors.of(context).muted),
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
                       Text(watchAdUnlockLabel(context)),
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
                     Text(unlockAllPairsForeverLabel(context)),
                   ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.btnCancel ?? 'Cancel', style: TextStyle(color: AppColors.of(context).subtle)),
            ),
          ],
        ),
      ),
    );
  }
}
