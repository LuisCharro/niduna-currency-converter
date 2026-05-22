import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class CurrencyRowSwipeActions extends StatefulWidget {
  const CurrencyRowSwipeActions({
    required this.code,
    required this.child,
    required this.isOpen,
    required this.onOpenChanged,
    required this.onRemove,
    required this.onSwap,
    super.key,
  });

  final String code;
  final Widget child;
  final bool isOpen;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback onRemove;
  final VoidCallback onSwap;

  @override
  State<CurrencyRowSwipeActions> createState() => _CurrencyRowSwipeActionsState();
}

class _CurrencyRowSwipeActionsState extends State<CurrencyRowSwipeActions> {
  static const double _actionWidth = 60;
  static const double _maxReveal = 184;
  static const Duration _duration = Duration(milliseconds: 220);

  double _reveal = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _reveal = widget.isOpen ? _maxReveal : 0;
  }

  @override
  void didUpdateWidget(covariant CurrencyRowSwipeActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDragging || oldWidget.isOpen == widget.isOpen) return;
    _reveal = widget.isOpen ? _maxReveal : 0;
  }

  @override
  Widget build(BuildContext context) {
    final baseProgress = _windowProgress(_reveal, start: 18, end: 138);
    final hideProgress = _windowProgress(_reveal, start: 86, end: 182);
    final rail = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          border: Border.all(color: AppTheme.border.withValues(alpha: .08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _ActionButton(
              actionKey: Key('remove_${widget.code}'),
              icon: Icons.remove_circle_rounded,
              backgroundColor: const Color(0xFFF7E3DC),
              iconBadgeColor: const Color(0xFFEBC0B3),
              color: AppTheme.coralInk,
              label: 'Remove currency',
              shortLabel: 'Hide',
              progress: _motionProgress(hideProgress),
              onTap: _handleRemove,
            ),
            _ActionButton(
              actionKey: Key('swap_${widget.code}'),
              icon: Icons.currency_exchange_rounded,
              backgroundColor: const Color(0xFF2E6940),
              iconBadgeColor: const Color(0xFF447E55),
              color: AppTheme.card,
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
              onTap: widget.isOpen ? () => widget.onOpenChanged(false) : null,
              onHorizontalDragStart: (_) => _isDragging = true,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _reveal = (_reveal - details.delta.dx).clamp(0, _maxReveal);
                });
              },
              onHorizontalDragEnd: (details) {
                final shouldOpen =
                    details.primaryVelocity == null
                        ? _reveal > 64
                        : details.primaryVelocity! < -180 || _reveal > 64;
                _finishDrag(shouldOpen);
              },
              onHorizontalDragCancel: () => _finishDrag(widget.isOpen),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppTheme.primary.withValues(
                        alpha: 0.04 + (0.04 * (_reveal / _maxReveal)),
                      ),
                      blurRadius: 8 + (4 * (_reveal / _maxReveal)),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.child,
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
      _reveal = open ? _maxReveal : 0;
    });
    widget.onOpenChanged(open);
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
          ignoring: clampedProgress < 0.55,
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
