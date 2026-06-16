import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';

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

  double _windowProgress(double value, {required double start, required double end}) {
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
    final strings = AppLocalizations.of(context);
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
              shortLabel: strings?.btnRemove ?? 'Hide',
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
                  ? strings?.favoriteActionSaved ?? 'Saved'
                  : strings?.favoriteActionPin ?? 'Pin',
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

class SwipeActionButton extends StatelessWidget {
  const SwipeActionButton({
    required Key actionKey,
    required this.icon,
    required this.backgroundColor,
    required this.iconBadgeColor,
    required this.color,
    required this.label,
    required this.shortLabel,
    required this.progress,
    required this.onTap,
  }) : super(key: actionKey);

  static const double actionWidth = 60;

  final IconData icon;
  final Color backgroundColor;
  final Color iconBadgeColor;
  final Color color;
  final String label;
  final String shortLabel;
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
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color.lerp(
                                    backgroundColor,
                                    iconBadgeColor,
                                    0.9,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                shortLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                  height: 1,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
