import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Rates ledger header with light Edit affordance (D2-CON-5).
class RatesSectionHeader extends StatelessWidget {
  const RatesSectionHeader({required this.onEdit, super.key});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        AppTheme.space2,
        AppTheme.pagePadding,
        AppTheme.space2,
      ),
      child: Row(
        children: <Widget>[
          Text(
            'RATES',
            style: AppTheme.sectionLabel.copyWith(color: AppTheme.muted),
          ),
          const Spacer(),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space3),
              minimumSize: const Size(48, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Edit',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
