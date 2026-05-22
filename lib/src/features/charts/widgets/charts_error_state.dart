import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/inline_empty_panel.dart';

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
    return Center(
      child: SingleChildScrollView(
        padding: AppTheme.pageInsets,
        child: InlineEmptyPanel(
          compact: true,
          icon: Icons.wifi_off_outlined,
          title: message ?? 'Failed to load chart data',
          actionLabel: 'Retry',
          actionKey: const Key('charts_retry'),
          onAction: onRetry,
        ),
      ),
    );
  }
}
