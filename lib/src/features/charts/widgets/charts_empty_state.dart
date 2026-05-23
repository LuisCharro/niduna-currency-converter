import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/designed_state_panel.dart';

class ChartsEmptyState extends StatelessWidget {
  const ChartsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: DesignedStatePanel(
        compact: true,
        icon: Icons.show_chart_rounded,
        title: l10n?.noRatesTitle ?? 'No history yet',
        subtitle: 'Try another range or currency pair',
        accent: AppTheme.primary,
      ),
    );
  }
}
