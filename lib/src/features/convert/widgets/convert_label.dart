import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ConvertLabel extends StatelessWidget {
  const ConvertLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: AppColors.of(context).muted,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: .6,
    ),
  );
}
