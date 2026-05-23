import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class InstrumentSectionLabel extends StatelessWidget {
  const InstrumentSectionLabel({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: AppTheme.caption.copyWith(
                  color: colors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle case final subtitle?) ...<Widget>[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: AppTheme.caption.copyWith(color: colors.muted),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
