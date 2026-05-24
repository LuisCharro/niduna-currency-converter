import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTheme.sectionLabelStyle(context).copyWith(
          color: AppColors.of(context).primary,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
