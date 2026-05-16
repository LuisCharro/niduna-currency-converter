import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class RemoveAdsButton extends StatelessWidget {
  const RemoveAdsButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
        decoration: BoxDecoration(
          color: AppTheme.container.withValues(alpha: .58),
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          border: Border.all(color: AppTheme.border.withValues(alpha: .18)),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.favorite_border_rounded,
              size: 16,
              color: AppTheme.primary.withValues(alpha: .72),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ads support Niduna',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.caption.copyWith(color: AppTheme.muted),
              ),
            ),
            TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppTheme.primary,
                backgroundColor: AppTheme.card.withValues(alpha: .82),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  side: BorderSide(
                    color: AppTheme.primary.withValues(alpha: .16),
                  ),
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Remove ads'),
            ),
          ],
        ),
      ),
    );
  }
}
