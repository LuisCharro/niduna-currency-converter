import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class RatesStatusCard extends StatelessWidget {
  const RatesStatusCard({
    required this.label,
    required this.message,
    required this.onRetry,
    required this.showRetry,
    super.key,
  });

  final String label;
  final String? message;
  final VoidCallback onRetry;
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.container.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.circle, size: 8, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message == null ? label : '$label · $message',
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showRetry)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
