import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Shared layout for the short Settings help pages.
class SettingsInfoPage extends StatelessWidget {
  const SettingsInfoPage({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.text,
        elevation: 0,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: children,
      ),
    );
  }

  static Widget paragraph(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppTheme.space5),
    child: Text(
      text,
      style: AppTheme.body.copyWith(
        color: AppColors.of(context).muted,
        height: 1.5,
      ),
    ),
  );
}
