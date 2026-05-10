import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class LockedPairActionSheet extends StatelessWidget {
  const LockedPairActionSheet({
    required this.onWatchAd,
    required this.onBuyForever,
    super.key,
  });

  final VoidCallback onWatchAd;
  final VoidCallback onBuyForever;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.lock_outline, size: 40, color: AppTheme.muted),
            const SizedBox(height: 12),
            Text(
              'This pair is locked',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.text),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how to unlock it',
              style: TextStyle(fontSize: 13, color: AppTheme.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.tonal(
                onPressed: onWatchAd,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.play_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Text('Watch ad · Unlock for 24h'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: onBuyForever,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.diamond_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Unlock all pairs forever'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: AppTheme.subtle)),
            ),
          ],
        ),
      ),
    );
  }
}
