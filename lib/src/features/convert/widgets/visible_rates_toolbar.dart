import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class VisibleRatesToolbar extends StatelessWidget {
  const VisibleRatesToolbar({
    required this.count,
    required this.onEdit,
    super.key,
  });

  final int count;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$count currencies shown',
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add / remove'),
          ),
        ],
      ),
    );
  }
}
