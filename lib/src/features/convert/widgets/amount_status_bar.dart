import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AmountStatusBar extends StatelessWidget {
  const AmountStatusBar({
    required this.isRefreshing,
    required this.lastUpdatedLabel,
    required this.onRefresh,
    required this.onMore,
    super.key,
  });

  final bool isRefreshing;
  final String lastUpdatedLabel;
  final Future<void> Function() onRefresh;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final label = isRefreshing ? 'Refreshing rates' : lastUpdatedLabel;
    return Row(
      children: <Widget>[
        Expanded(
          child: Tooltip(
            message: 'Rates update once per day from the European Central Bank',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _StatusDot(active: isRefreshing),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _ActionButton(
          tooltip: 'Refresh rates',
          icon: Icons.sync_rounded,
          onPressed: onRefresh,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          tooltip: 'Settings',
          icon: Icons.tune_rounded,
          onPressed: onMore,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.card.withValues(alpha: .72),
        foregroundColor: AppTheme.primary,
        fixedSize: const Size(42, 42),
        minimumSize: const Size(42, 42),
        padding: EdgeInsets.zero,
        side: BorderSide(color: AppTheme.border.withValues(alpha: .16)),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : AppTheme.trendUp,
        shape: BoxShape.circle,
      ),
    );
  }
}
