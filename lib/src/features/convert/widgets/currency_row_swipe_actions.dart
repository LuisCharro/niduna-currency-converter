import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class CurrencyRowSwipeActions extends StatefulWidget {
  const CurrencyRowSwipeActions({
    required this.code,
    required this.child,
    required this.isOpen,
    required this.onOpenChanged,
    required this.onRemove,
    required this.onSwap,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.onPressed,
    super.key,
  });

  final String code;
  final Widget child;
  final bool isOpen;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback onRemove;
  final VoidCallback onSwap;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;
  final ValueChanged<Offset> onPressed;

  @override
  State<CurrencyRowSwipeActions> createState() =>
      _CurrencyRowSwipeActionsState();
}

class _CurrencyRowSwipeActionsState extends State<CurrencyRowSwipeActions>
    with TickerProviderStateMixin {
  static const double _actionWidth = 60;
  static const double _maxReveal = 244;
  static const Duration _duration = Duration(milliseconds: 220);
  static const Duration _pressDuration = Duration(milliseconds: 160);
  static const Duration _chargeDuration = Duration(milliseconds: 800);

  double _reveal = 0;
  bool _isDragging = false;
  bool _isPressed = false;
  bool _isHolding = false;
  Offset? _tapPosition;
  Offset? _localTapPosition;

  late AnimationController _chargeController;
  double _lastHapticThreshold = 0;

  @override
  void initState() {
    super.initState();
    _reveal = widget.isOpen ? _maxReveal : 0;
    _chargeController =
        AnimationController(vsync: this, duration: _chargeDuration)
          ..addStatusListener(_onChargeStatusChanged)
          ..addListener(_onChargeProgress);
  }

  @override
  void dispose() {
    _chargeController.removeListener(_onChargeProgress);
    _chargeController.dispose();
    super.dispose();
  }

  void _onChargeProgress() {
    final value = _chargeController.value;
    if (value >= 0.4 && _lastHapticThreshold < 0.4) {
      _lastHapticThreshold = 0.4;
      HapticFeedback.selectionClick();
    }
    if (value >= 0.75 && _lastHapticThreshold < 0.75) {
      _lastHapticThreshold = 0.75;
      HapticFeedback.lightImpact();
    }
  }

  void _onChargeStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isHolding && !widget.isOpen) {
      HapticFeedback.mediumImpact();
      _cancelCharge();
      widget.onPressed(_tapPosition ?? Offset.zero);
    }
  }

  @override
  void didUpdateWidget(covariant CurrencyRowSwipeActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDragging || oldWidget.isOpen == widget.isOpen) return;
    _reveal = widget.isOpen ? _maxReveal : 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final baseProgress = _windowProgress(_reveal, start: 18, end: 138);
    final hideProgress = _windowProgress(_reveal, start: 86, end: 182);
    final revealProgress = _reveal / _maxReveal;
    final rail = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border.withValues(alpha: .08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _ActionButton(
              actionKey: Key('remove_${widget.code}'),
              icon: Icons.remove_circle_rounded,
              backgroundColor: const Color(0xFFF7E3DC),
              iconBadgeColor: const Color(0xFFEBC0B3),
              color: colors.coralInk,
              label: 'Remove currency',
              shortLabel: l10n?.btnRemove ?? 'Hide',
              progress: _motionProgress(hideProgress),
              onTap: _handleRemove,
            ),
            _ActionButton(
              actionKey: Key('favorite_${widget.code}'),
              icon: widget.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              backgroundColor: colors.containerHigh,
              iconBadgeColor: colors.greenBadge,
              color: colors.primary,
              label: widget.isFavorite
                  ? l10n?.removeFavoriteTooltip ?? 'Remove favorite'
                  : l10n?.labelAddFavorite ?? 'Add favorite',
              shortLabel: widget.isFavorite
                  ? l10n?.favoriteActionSaved ?? 'Saved'
                  : l10n?.favoriteActionPin ?? 'Pin',
              progress: _motionProgress(baseProgress),
              onTap: _handleFavorite,
            ),
            _ActionButton(
              actionKey: Key('swap_${widget.code}'),
              icon: Icons.currency_exchange_rounded,
              backgroundColor: const Color(0xFF2E6940),
              iconBadgeColor: const Color(0xFF447E55),
              color: colors.card,
              label: 'Set as base currency',
              shortLabel: 'Base',
              progress: _motionProgress(baseProgress),
              onTap: _handleSwap,
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      height: AppTheme.rowMinHeight,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: rail),
          AnimatedPositioned(
            duration: _isDragging ? Duration.zero : _duration,
            curve: Curves.easeOutCubic,
            left: -_reveal,
            right: _reveal,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                _tapPosition = details.globalPosition;
                _localTapPosition = details.localPosition;
                if (widget.isOpen) return;
                _setPressed(true, withHaptic: true);
                _isHolding = true;
                _lastHapticThreshold = 0;
                _chargeController.forward(from: 0);
              },
              onTapUp: (_) {
                _setPressed(false);
                _cancelCharge();
              },
              onTapCancel: () {
                _setPressed(false);
                _cancelCharge();
              },
              onTap: () {
                _setPressed(false);
                if (widget.isOpen) {
                  widget.onOpenChanged(false);
                  return;
                }
              },
              onHorizontalDragStart: (_) {
                _setPressed(false);
                _cancelCharge();
                _isDragging = true;
              },
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _reveal = (_reveal - details.delta.dx).clamp(0, _maxReveal);
                });
              },
              onHorizontalDragEnd: (details) {
                final shouldOpen = details.primaryVelocity == null
                    ? _reveal > 64
                    : details.primaryVelocity! < -180 || _reveal > 64;
                _finishDrag(shouldOpen);
              },
              onHorizontalDragCancel: () => _finishDrag(widget.isOpen),
              child: AnimatedScale(
                duration: _pressDuration,
                curve: Curves.easeOutCubic,
                scale: _isPressed ? 1.018 : 1,
                child: AnimatedContainer(
                  duration: _pressDuration,
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.translationValues(
                    0,
                    _isPressed ? -2 : 0,
                    0,
                  ),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colors.primary.withValues(
                          alpha: _isPressed
                              ? 0.1
                              : 0.04 + (0.04 * revealProgress),
                        ),
                        blurRadius: _isPressed ? 16 : 8 + (4 * revealProgress),
                        offset: Offset(0, _isPressed ? 6 : 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: <Widget>[
                        widget.child,
                        AnimatedBuilder(
                          animation: _chargeController,
                          builder: (context, _) {
                            if (_chargeController.value == 0 ||
                                _localTapPosition == null) {
                              return const SizedBox.shrink();
                            }
                            return Positioned.fill(
                              child: CustomPaint(
                                painter: _RadialFillPainter(
                                  progress: _chargeController.value,
                                  center: _localTapPosition!,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finishDrag(bool open) {
    setState(() {
      _isDragging = false;
      _isPressed = false;
      _reveal = open ? _maxReveal : 0;
    });
    widget.onOpenChanged(open);
  }

  void _setPressed(bool value, {bool withHaptic = false}) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
    if (value && withHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _cancelCharge() {
    _isHolding = false;
    _chargeController.stop();
    if (_chargeController.value > 0) {
      _chargeController.animateTo(
        0,
        duration: const Duration(milliseconds: 120),
      );
    }
  }

  void _handleRemove() {
    HapticFeedback.mediumImpact();
    widget.onOpenChanged(false);
    widget.onRemove();
  }

  void _handleSwap() {
    HapticFeedback.selectionClick();
    widget.onOpenChanged(false);
    widget.onSwap();
  }

  void _handleFavorite() {
    HapticFeedback.selectionClick();
    widget.onOpenChanged(false);
    widget.onToggleFavorite();
  }

  double _motionProgress(double progress) {
    if (progress <= 0) return 0;
    if (progress >= 1) return 1;
    return Curves.easeOutCubic.transform(progress);
  }

  double _windowProgress(
    double reveal, {
    required double start,
    required double end,
  }) {
    if (reveal <= start) return 0;
    if (reveal >= end) return 1;
    return (reveal - start) / (end - start);
  }
}

class _RadialFillPainter extends CustomPainter {
  const _RadialFillPainter({required this.progress, required this.center});

  final double progress;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) * 0.6;
    final easedProgress = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final radius = maxRadius * easedProgress;
    final opacity = Curves.easeIn.transform(progress.clamp(0.0, 1.0));
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Color.fromRGBO(45, 106, 70, opacity * 0.15),
    );
  }

  @override
  bool shouldRepaint(_RadialFillPainter oldDelegate) =>
      progress != oldDelegate.progress || center != oldDelegate.center;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
        width: _CurrencyRowSwipeActionsState._actionWidth,
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
