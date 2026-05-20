import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class NoRatesCard extends StatelessWidget {
  const NoRatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: AppTheme.container.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.currency_exchange_outlined,
              size: 44,
              color: AppTheme.subtle,
            ),
            const SizedBox(height: 14),
            Text(
              'Rates will appear here',
              style: AppTheme.body.copyWith(color: AppTheme.text),
            ),
            const SizedBox(height: 4),
            Text(
              'Pull to refresh or tap the sync button',
              style: AppTheme.caption.copyWith(color: AppTheme.subtle),
            ),
          ],
        ),
      ),
    );
  }
}
