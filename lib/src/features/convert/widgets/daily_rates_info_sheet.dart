import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class DailyRatesInfoSheet extends StatelessWidget {
  const DailyRatesInfoSheet({
    required this.lastUpdatedLabel,
    required this.nextUpdateLabel,
    super.key,
  });

  final String lastUpdatedLabel;
  final String nextUpdateLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Daily exchange rates', style: AppTheme.heading),
              const SizedBox(height: 12),
              Text(
                'The free version updates exchange rates once per day. They are '
                'useful for everyday conversion, but they are not minute-by-minute '
                'market prices.',
                style: AppTheme.body.copyWith(color: colors.muted),
              ),
              const SizedBox(height: 18),
              _InfoLine(
                icon: Icons.event_available_rounded,
                text: lastUpdatedLabel,
              ),
              const SizedBox(height: 10),
              _InfoLine(icon: Icons.schedule_rounded, text: nextUpdateLabel),
              const SizedBox(height: 18),
              Text(
                'The next expected update is shown in your local time.',
                style: AppTheme.caption.copyWith(color: colors.subtle),
              ),
              const SizedBox(height: 8),
              Text(
                'Faster updates are planned for a future Premium subscription.',
                style: AppTheme.caption.copyWith(color: colors.subtle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTheme.caption)),
      ],
    );
  }
}
