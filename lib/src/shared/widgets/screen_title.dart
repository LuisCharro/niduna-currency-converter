import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      key: const Key('screen_title'),
      style: AppTheme.screenTitleFraunces,
    );
  }
}
