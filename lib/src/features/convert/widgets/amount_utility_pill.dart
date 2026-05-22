import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AmountUtilityPill extends StatelessWidget {
  const AmountUtilityPill({
    required this.onRefresh,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _UtilityIconButton(
            key: const Key('convert_refresh'),
            tooltip: 'Refresh rates',
            icon: Icons.sync_rounded,
            onPressed: onRefresh,
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppTheme.border.withValues(alpha: .1),
            ),
          ),
          _UtilityIconButton(
            tooltip: 'Settings',
            icon: Icons.tune_rounded,
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}

class _UtilityIconButton extends StatelessWidget {
  const _UtilityIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    super.key,
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
        foregroundColor: AppTheme.primary,
        fixedSize: const Size(44, 44),
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
