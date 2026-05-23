import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Branded empty/error panel with forest icon treatment (G2-7, D2-CON-7).
class DesignedStatePanel extends StatelessWidget {
  const DesignedStatePanel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.accent = AppTheme.primary,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final topPad = compact ? AppTheme.space2 : AppTheme.space7;
    return Padding(
      key: const Key('designed_state_panel'),
      padding: EdgeInsets.fromLTRB(0, topPad, 0, AppTheme.space3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: compact ? 44 : 52,
            height: compact ? 44 : 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: .1),
              border: Border.all(color: accent.withValues(alpha: .22)),
            ),
            child: Icon(icon, size: compact ? 22 : 26, color: accent),
          ),
          SizedBox(height: compact ? AppTheme.space3 : AppTheme.space4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.body.copyWith(
              color: colors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: AppTheme.space1),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTheme.caption.copyWith(color: colors.muted),
            ),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: AppTheme.space4),
            TextButton(
              key: actionKey,
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: colors.primary),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
