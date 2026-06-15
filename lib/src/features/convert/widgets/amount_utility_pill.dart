import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class AmountUtilityPill extends StatelessWidget {
  const AmountUtilityPill({
    required this.onRefresh,
    required this.onShare,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final VoidCallback? onShare;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: colors.border.withValues(alpha: .12)),
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
              color: colors.border.withValues(alpha: .1),
            ),
          ),
          _UtilityIconButton(
            key: const Key('convert_share'),
            tooltip: 'Share rates',
            icon: Icons.ios_share_rounded,
            onPressed: onShare,
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: colors.border.withValues(alpha: .1),
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
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        foregroundColor: colors.primary,
        fixedSize: const Size(44, 44),
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
