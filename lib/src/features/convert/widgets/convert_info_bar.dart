import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ConvertInfoBar extends StatelessWidget {
  const ConvertInfoBar({
    required this.statusLabel,
    required this.message,
    required this.count,
    required this.onEdit,
    super.key,
  });

  final String statusLabel;
  final String? message;
  final int count;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final details = message == null
        ? '$statusLabel · $count currencies'
        : '$statusLabel · $message · $count currencies';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppTheme.container.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.circle, size: 7, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                details,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
