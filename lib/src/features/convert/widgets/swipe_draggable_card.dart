import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class SwipeDraggableCard extends StatefulWidget {
  const SwipeDraggableCard({
    required this.isOpen,
    required this.reveal,
    required this.onRevealChanged,
    required this.onOpenChanged,
    required this.onPressed,
    required this.child,
    super.key,
  });
  final bool isOpen;
  final double reveal;
  final ValueChanged<double> onRevealChanged;
  final ValueChanged<bool> onOpenChanged;
  final ValueChanged<Offset> onPressed;
  final Widget child;
  static const double maxReveal = 244;
  static const Duration _duration = Duration(milliseconds: 220);
  static const Duration _pressDuration = Duration(milliseconds: 160);
  static const Duration _chargeDuration = Duration(milliseconds: 800);
  @override
  State<SwipeDraggableCard> createState() => _SwipeDraggableCardState();
}

class _SwipeDraggableCardState extends State<SwipeDraggableCard>
    with TickerProviderStateMixin {
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
    _reveal = widget.reveal;
    _chargeController = AnimationController(
      vsync: this,
      duration: SwipeDraggableCard._chargeDuration,
    )
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
    final v = _chargeController.value;
    if (v >= 0.4 && _lastHapticThreshold < 0.4) {
      _lastHapticThreshold = 0.4;
      HapticFeedback.selectionClick();
    }
    if (v >= 0.75 && _lastHapticThreshold < 0.75) {
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
  void didUpdateWidget(covariant SwipeDraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDragging || oldWidget.isOpen == widget.isOpen) return;
    setState(() => _reveal = widget.isOpen ? SwipeDraggableCard.maxReveal : 0);
  }

  void _release() {
    _setPressed(false);
    _cancelCharge();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final revealProgress = _reveal / SwipeDraggableCard.maxReveal;
    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : SwipeDraggableCard._duration,
      curve: Curves.easeOutCubic,
      left: -_reveal,
      right: _reveal,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (d) {
          _tapPosition = d.globalPosition;
          _localTapPosition = d.localPosition;
          if (widget.isOpen) return;
          _setPressed(true, withHaptic: true);
          _isHolding = true;
          _lastHapticThreshold = 0;
          _chargeController.forward(from: 0);
        },
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        onTap: () {
          _setPressed(false);
          if (widget.isOpen) {
            widget.onOpenChanged(false);
            return;
          }
        },
        onHorizontalDragStart: (_) {
          _release();
          setState(() => _isDragging = true);
        },
        onHorizontalDragUpdate: (d) {
          setState(() {
            _reveal =
                (_reveal - d.delta.dx).clamp(0.0, SwipeDraggableCard.maxReveal);
          });
          widget.onRevealChanged(_reveal);
        },
        onHorizontalDragEnd: (d) => _finishDrag(
          d.primaryVelocity == null
              ? _reveal > 64
              : d.primaryVelocity! < -180 || _reveal > 64,
        ),
        onHorizontalDragCancel: () => _finishDrag(widget.isOpen),
        child: AnimatedScale(
          duration: SwipeDraggableCard._pressDuration,
          curve: Curves.easeOutCubic,
          scale: _isPressed ? 1.018 : 1,
          child: AnimatedContainer(
            duration: SwipeDraggableCard._pressDuration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _isPressed ? -2 : 0, 0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.primary.withValues(
                    alpha:
                        _isPressed ? 0.1 : 0.04 + (0.04 * revealProgress),
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
    );
  }

  void _finishDrag(bool open) {
    setState(() {
      _isDragging = false;
      _isPressed = false;
      _reveal = open ? SwipeDraggableCard.maxReveal : 0;
    });
    widget.onRevealChanged(_reveal);
    widget.onOpenChanged(open);
  }

  void _setPressed(bool value, {bool withHaptic = false}) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
    if (value && withHaptic) HapticFeedback.lightImpact();
  }

  void _cancelCharge() {
    _isHolding = false;
    _chargeController.stop();
    if (_chargeController.value > 0) {
      _chargeController
          .animateTo(0, duration: const Duration(milliseconds: 120));
    }
  }
}

class _RadialFillPainter extends CustomPainter {
  const _RadialFillPainter({required this.progress, required this.center});
  final double progress;
  final Offset center;
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final r =
        math.sqrt(size.width * size.width + size.height * size.height) * 0.6;
    final ep = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final op = Curves.easeIn.transform(progress.clamp(0.0, 1.0));
    canvas.drawCircle(
        center, r * ep, Paint()..color = Color.fromRGBO(45, 106, 70, op * .15));
  }

  @override
  bool shouldRepaint(_RadialFillPainter old) =>
      progress != old.progress || center != old.center;
}
