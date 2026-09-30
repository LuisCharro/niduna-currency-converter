import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Round toolbar chrome shared by Convert's amount-card utility pill and
/// Favorites' header pill: a card-tinted rounded container hosting a row of
/// icon buttons (with any dividers already included in [children]).
class ToolbarPill extends StatelessWidget {
  const ToolbarPill({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: .46),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: colors.border.withValues(alpha: .10)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
