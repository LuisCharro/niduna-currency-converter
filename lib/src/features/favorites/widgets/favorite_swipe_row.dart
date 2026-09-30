import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/single_swipe_action_rail.dart';
import '../../../shared/widgets/swipe_draggable_card.dart';
import '../domain/favorite_pair.dart';

/// Swipe-left-to-reveal-Remove + long-press-to-reorder wrapper shared by the
/// Favorites hero card and its plain rows.
///
/// The long-press "charge" that lets Convert's rail open without dragging is
/// disabled here: a long press is reserved for [ReorderableDelayedDragStartListener]
/// to start dragging the item instead.
class FavoriteSwipeRow extends StatefulWidget {
  const FavoriteSwipeRow({
    required this.pair,
    required this.index,
    required this.onOpen,
    required this.onRemove,
    required this.onMoveUp,
    required this.child,
    this.height,
    this.surface = SwipeCardSurface.plain,
    super.key,
  });

  static const double maxReveal = 92;

  final FavoritePair pair;
  final int index;

  /// A fixed row height (rows use this: a stable height keeps drag-reorder
  /// math and the fixed swipe-reveal rail simple). When null (the hero
  /// card), the swipe stack instead sizes itself to [child]'s own natural
  /// height via an invisible sizing proxy, so the card never reserves more
  /// vertical space than its content actually needs.
  final double? height;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final Widget child;

  /// [SwipeCardSurface.plain] for rows (flush with the page canvas, per
  /// DESIGN.md: "no card, no border, no shadow"); the hero card passes
  /// [SwipeCardSurface.card] to mirror Convert's elevated amount card.
  final SwipeCardSurface surface;

  @override
  State<FavoriteSwipeRow> createState() => _FavoriteSwipeRowState();
}

class _FavoriteSwipeRowState extends State<FavoriteSwipeRow> {
  double _reveal = 0;
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    return ReorderableDelayedDragStartListener(
      index: widget.index,
      child: Semantics(
        customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
          CustomSemanticsAction(label: loc.openFavoriteTooltip): widget.onOpen,
          CustomSemanticsAction(label: loc.removeFavoriteTooltip):
              _handleRemove,
          if (widget.onMoveUp != null)
            CustomSemanticsAction(label: loc.reorderFavoriteTooltip):
                widget.onMoveUp!,
        },
        child: _sizedStack(colors, loc),
      ),
    );
  }

  Widget _sizedStack(AppColors colors, AppLocalizations loc) {
    final stack = Stack(
      children: <Widget>[
        // Invisible sizing proxy (hero only, when `height` is null): a Stack
        // sizes itself to its largest *non*-positioned child, but the rail
        // and the sliding card below are both positioned, so without this
        // the Stack would have nothing to size itself from. Mirroring the
        // real content here (off-screen, non-interactive) makes the Stack —
        // and so the swipe card behind it — exactly as tall as the content
        // actually needs, instead of a guessed fixed height that can leave
        // empty space below on a taller device.
        if (widget.height == null)
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: widget.child,
          ),
        Positioned.fill(
          child: SingleSwipeActionRail(
            actionKey: Key('remove_${widget.pair.toKey()}'),
            icon: Icons.remove_circle_rounded,
            label: loc.removeFavoriteTooltip,
            shortLabel: loc.btnRemove,
            color: colors.coralInk,
            backgroundColor: colors.coralSurface,
            reveal: _reveal,
            maxReveal: FavoriteSwipeRow.maxReveal,
            onTap: _handleRemove,
          ),
        ),
        SwipeDraggableCard(
          reveal: _reveal,
          maxReveal: FavoriteSwipeRow.maxReveal,
          isOpen: _isOpen,
          enableLongPressCharge: false,
          surface: widget.surface,
          onRevealChanged: (value) => setState(() => _reveal = value),
          onOpenChanged: _onOpenChanged,
          onPressed: (_) {},
          // Forces the foreground to be at least as tall as a fixed row
          // (matching Convert's own `ConstrainedBox(minHeight: ...)` pattern
          // in CurrencyRateRow): otherwise, since a Positioned without
          // top/bottom shrink-wraps to its content, a content block shorter
          // than `height` would leave the rail peeking out below it even
          // while closed. Not needed for the hero (null height): the sizing
          // proxy above already guarantees an exact content-height match.
          child: widget.height == null
              ? _openInkWell()
              : ConstrainedBox(
                  constraints: BoxConstraints(minHeight: widget.height!),
                  child: _openInkWell(),
                ),
        ),
      ],
    );
    return widget.height == null
        ? stack
        : SizedBox(height: widget.height, child: stack);
  }

  Widget _openInkWell() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('open_${widget.pair.toKey()}'),
        onTap: _handleTap,
        child: widget.child,
      ),
    );
  }

  void _onOpenChanged(bool open) {
    setState(() {
      _isOpen = open;
      _reveal = open ? FavoriteSwipeRow.maxReveal : 0;
    });
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    if (_isOpen) return;
    widget.onOpen();
  }

  void _handleRemove() {
    HapticFeedback.mediumImpact();
    _onOpenChanged(false);
    widget.onRemove();
  }
}
