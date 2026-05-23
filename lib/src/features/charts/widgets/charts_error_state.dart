import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/designed_state_panel.dart';

class ChartsErrorState extends StatelessWidget {
  const ChartsErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: DesignedStatePanel(
        compact: true,
        icon: Icons.wifi_off_rounded,
        accent: AppTheme.trendDown,
        title: message ?? 'Offline — showing cache',
        subtitle: 'Check your connection and try again',
        actionLabel: l10n?.btnRefresh ?? 'Retry',
        actionKey: const Key('charts_retry'),
        onAction: onRetry,
      ),
    );
  }
}
