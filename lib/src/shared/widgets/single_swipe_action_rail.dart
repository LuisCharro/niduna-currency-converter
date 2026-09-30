import 'package:flutter/material.dart';

import 'swipe_action_button.dart';

/// A one-action swipe rail (e.g. Favorites' coral "Remove"), sized to a
/// single [SwipeActionButton]. Convert's 3-action rail stays bespoke
/// (`SwipeActionsRail`) since it also offers Base/Favorite.
class SingleSwipeActionRail extends StatelessWidget {
  const SingleSwipeActionRail({
    required this.actionKey,
    required this.icon,
    required this.label,
    required this.shortLabel,
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
  final String shortLabel;
  final Color color;
  final Color backgroundColor;
  final double reveal;
  final double maxReveal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (reveal / maxReveal).clamp(0.0, 1.0);
    // No persistent background here (unlike Convert's 3-action rail): the
    // rail itself must be invisible while closed, and only the action tile
    // — which already fades itself in via [SwipeActionButton]'s own
    // opacity — should ever paint anything.
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SwipeActionButton(
          actionKey: actionKey,
          icon: icon,
          backgroundColor: backgroundColor,
          iconBadgeColor: color,
          color: color,
          label: label,
          shortLabel: shortLabel,
          progress: Curves.easeOutCubic.transform(progress),
          onTap: onTap,
        ),
      ],
    );
  }
}
