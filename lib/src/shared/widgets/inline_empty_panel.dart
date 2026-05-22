import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class InlineEmptyPanel extends StatelessWidget {
  const InlineEmptyPanel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final topPad = compact ? 8.0 : 28.0;
    final iconSize = compact ? 36.0 : 44.0;
    return Padding(
      key: const Key('inline_empty_panel'),
      padding: EdgeInsets.fromLTRB(0, topPad, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: iconSize, color: AppTheme.subtle),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.body.copyWith(color: AppTheme.text),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTheme.caption.copyWith(color: AppTheme.muted),
            ),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: 14),
            TextButton(
              key: actionKey,
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
