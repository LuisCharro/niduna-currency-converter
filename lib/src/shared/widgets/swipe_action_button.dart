import 'package:flutter/material.dart';
import 'swipe_action_layout.dart';

/// One action tile inside a swipe-reveal actions rail (behind a
/// [SwipeDraggableCard]): an icon with an accessible label, fading and
/// sliding in as the card reveals it.
class SwipeActionButton extends StatelessWidget {
  const SwipeActionButton({
    required Key actionKey,
    required this.icon,
    required this.backgroundColor,
    required this.color,
    required this.label,
    required this.progress,
    required this.onTap,
  }) : super(key: actionKey);

  static const double actionWidth = SwipeActionLayout.buttonWidth;

  final IconData icon;
  final Color backgroundColor;
  final Color color;
  final String label;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final easedScale = Curves.easeInOut.transform(clampedProgress);
    final easedSlide = Curves.easeOutCubic.transform(clampedProgress);
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: actionWidth,
        child: IgnorePointer(
          ignoring: clampedProgress < 0.35,
          child: Opacity(
            opacity: clampedProgress,
            child: Transform.translate(
              offset: Offset(28 * (1 - easedSlide), 0),
              child: Transform.scale(
                scale: 0.38 + (0.62 * easedScale),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: Tooltip(
                      message: label,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.center,
                          child: Icon(icon, color: color, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
