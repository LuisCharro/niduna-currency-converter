import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Shared warm instrument surface (G2-4).
class InstrumentPanel extends StatelessWidget {
  const InstrumentPanel({
    required this.child,
    this.header,
    this.padding,
    super.key,
  });

  final Widget child;
  final Widget? header;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? colors.containerHigh.withValues(alpha: .62)
            : colors.card,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.border.withValues(alpha: isDark ? .15 : .20),
        ),
        boxShadow: isDark
            ? null
            : AppTheme.subtleShadowFor(context),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (header != null) ...<Widget>[
              header!,
              const SizedBox(height: AppTheme.space3),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
