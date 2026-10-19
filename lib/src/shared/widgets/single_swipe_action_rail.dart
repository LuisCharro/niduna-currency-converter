import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import 'swipe_action_button.dart';
import 'swipe_action_layout.dart';

/// A one-action swipe rail (e.g. Favorites' coral "Remove"), sized to a
/// single [SwipeActionButton]. Convert's 3-action rail stays bespoke
/// (`SwipeActionsRail`) since it also offers Base/Favorite.
class SingleSwipeActionRail extends StatelessWidget {
  const SingleSwipeActionRail({
    required this.actionKey,
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.reveal,
    required this.maxReveal,
    required this.onTap,
    super.key,
  });

  final Key actionKey;
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final double reveal;
  final double maxReveal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (reveal / maxReveal).clamp(0.0, 1.0);
    final colors = AppColors.of(context);
    // Match Convert's action tray when revealed, but paint nothing closed.
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: maxReveal,
        height: SwipeActionLayout.trayHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: progress),
              border: Border.all(
                color: colors.border.withValues(alpha: .08 * progress),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SwipeActionButton(
                  actionKey: actionKey,
                  icon: icon,
                  backgroundColor: backgroundColor,
                  color: color,
                  label: label,
                  progress: Curves.easeOutCubic.transform(progress),
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
