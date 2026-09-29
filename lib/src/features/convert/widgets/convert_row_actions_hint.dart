import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// One-time, dismissible hint explaining the hidden row gestures (hold to
/// open the Conversion Lens, swipe left for Remove/Favorite/Base).
class ConvertRowActionsHint extends StatelessWidget {
  const ConvertRowActionsHint({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      key: const Key('convert_row_actions_hint'),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        0,
        AppTheme.pagePadding,
        AppTheme.space2,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.container.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: colors.border.withValues(alpha: .14)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space3,
            vertical: AppTheme.space2,
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.touch_app_rounded, size: 16, color: colors.subtle),
              const SizedBox(width: AppTheme.space2),
              Expanded(
                child: Text(
                  convertRowActionsHintText(context),
                  style: AppTheme.caption.copyWith(
                    color: colors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              GestureDetector(
                key: const Key('convert_row_actions_hint_dismiss'),
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.subtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
