import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ConvertLabel extends StatelessWidget {
  const ConvertLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.muted,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: .6,
    ),
  );
}
