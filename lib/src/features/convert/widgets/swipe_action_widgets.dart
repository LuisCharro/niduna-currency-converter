import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/swipe_action_button.dart';

class SwipeActionsRail extends StatelessWidget {
  const SwipeActionsRail({
    required this.code,
    required this.isFavorite,
    required this.reveal,
    required this.onRemove,
    required this.onSwap,
    required this.onFavorite,
    super.key,
  });

  final String code;
  final bool isFavorite;
  final double reveal;
  final VoidCallback onRemove;
  final VoidCallback onSwap;
  final VoidCallback onFavorite;

  double _windowProgress(
    double value, {
    required double start,
    required double end,
  }) {
    if (value <= start) return 0;
    if (value >= end) return 1;
    return (value - start) / (end - start);
  }

  double _motionProgress(double progress) {
    if (progress <= 0) return 0;
    if (progress >= 1) return 1;
    return Curves.easeOutCubic.transform(progress);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    final hideProgress = _windowProgress(reveal, start: 86, end: 182);
    final baseProgress = _windowProgress(reveal, start: 18, end: 138);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border.withValues(alpha: .08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SwipeActionButton(
              actionKey: Key('remove_$code'),
              icon: Icons.remove_circle_rounded,
              backgroundColor: const Color(0xFFF7E3DC),
              iconBadgeColor: const Color(0xFFEBC0B3),
              color: colors.coralInk,
              label: loc.removeCurrencyLabel,
              shortLabel: loc.btnRemove,
              progress: _motionProgress(hideProgress),
              onTap: onRemove,
            ),
            SwipeActionButton(
              actionKey: Key('favorite_$code'),
              icon: isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              backgroundColor: colors.containerHigh,
              iconBadgeColor: colors.greenBadge,
              color: colors.primary,
              label: loc.toggleFavoriteLabel,
              shortLabel: isFavorite
                  ? loc.favoriteActionSaved
                  : loc.favoriteActionPin,
              progress: _motionProgress(baseProgress),
              onTap: onFavorite,
            ),
            SwipeActionButton(
              actionKey: Key('swap_$code'),
              icon: Icons.currency_exchange_rounded,
              backgroundColor: const Color(0xFF2E6940),
              iconBadgeColor: const Color(0xFF447E55),
              color: colors.card,
              label: loc.setAsBaseLabel,
              shortLabel: 'Base',
              progress: _motionProgress(baseProgress),
              onTap: onSwap,
            ),
          ],
        ),
      ),
    );
  }
}
