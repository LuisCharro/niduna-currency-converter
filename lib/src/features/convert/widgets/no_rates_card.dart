import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class NoRatesCard extends StatelessWidget {
  const NoRatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.currency_exchange_outlined,
            size: 48,
            color: AppTheme.subtle,
          ),
          const SizedBox(height: 16),
          Text(
            'Rates will appear here',
            style: AppTheme.body.copyWith(color: AppTheme.muted),
          ),
          const SizedBox(height: 4),
          Text(
            'Pull to refresh or tap the sync button',
            style: AppTheme.caption.copyWith(color: AppTheme.subtle),
          ),
        ],
      ),
    );
  }
}
