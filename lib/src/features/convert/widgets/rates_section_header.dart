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
          OutlinedButton.icon(
            key: const Key('open_currency_picker'),
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              backgroundColor: AppTheme.container.withValues(alpha: .55),
              side: BorderSide(color: AppTheme.border.withValues(alpha: .14)),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space3,
                vertical: 8,
              ),
              minimumSize: const Size(48, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Add currencies',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
