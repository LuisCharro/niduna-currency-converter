import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import 'swipe_action_widgets.dart';
import 'swipe_draggable_card.dart';

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

class _CurrencyRowSwipeActionsState extends State<CurrencyRowSwipeActions> {
  double _reveal = 0;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.isOpen;
    _reveal = widget.isOpen ? SwipeDraggableCard.maxReveal : 0;
  }

  @override
  void didUpdateWidget(covariant CurrencyRowSwipeActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen == widget.isOpen) return;
    _isOpen = widget.isOpen;
    _reveal = widget.isOpen ? SwipeDraggableCard.maxReveal : 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.rowMinHeight,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SwipeActionsRail(
              code: widget.code,
              isFavorite: widget.isFavorite,
              reveal: _reveal,
              onRemove: _handleRemove,
              onSwap: _handleSwap,
              onFavorite: _handleFavorite,
            ),
          ),
          SwipeDraggableCard(
            reveal: _reveal,
            isOpen: _isOpen,
            onRevealChanged: _onRevealChanged,
            onOpenChanged: _onOpenChanged,
            onPressed: widget.onPressed,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _onRevealChanged(double value) {
    setState(() => _reveal = value);
  }

  void _onOpenChanged(bool open) {
    setState(() {
      _isOpen = open;
      _reveal = open ? SwipeDraggableCard.maxReveal : 0;
    });
    widget.onOpenChanged(open);
  }

  void _handleRemove() {
    HapticFeedback.mediumImpact();
    _onOpenChanged(false);
    widget.onRemove();
  }

  void _handleSwap() {
    HapticFeedback.selectionClick();
    _onOpenChanged(false);
    widget.onSwap();
  }

  void _handleFavorite() {
    HapticFeedback.selectionClick();
    _onOpenChanged(false);
    widget.onToggleFavorite();
  }
}
