import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class NoRatesCard extends StatelessWidget {
  const NoRatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Text(
        'Rates will appear here after the first successful refresh.',
        style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700),
      ),
    );
  }
}
