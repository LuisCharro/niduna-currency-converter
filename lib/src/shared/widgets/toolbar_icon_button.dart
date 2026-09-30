import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// One icon action inside a [ToolbarPill].
class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconKey,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Key? iconKey;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return IconButton(
      key: iconKey,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
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

/// Hairline separator between two [ToolbarIconButton]s in a [ToolbarPill].
class ToolbarDivider extends StatelessWidget {
  const ToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 16,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: colors.border.withValues(alpha: .08),
      ),
    );
  }
}
