import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class FavoritesSwipeHintRow extends StatelessWidget {
  const FavoritesSwipeHintRow({required this.colors, super.key});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: .12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: <Widget>[
            Icon(Icons.euro_rounded, color: colors.primary),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Text(
                'EUR',
                style: AppTheme.settingsTileTitleStyle(context),
              ),
            ),
            Icon(Icons.swipe_left_rounded, size: 18, color: colors.subtle),
          ],
        ),
      ),
    );
  }
}
