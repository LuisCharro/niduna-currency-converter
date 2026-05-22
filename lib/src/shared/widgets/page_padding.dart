import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PagePadding extends StatelessWidget {
  const PagePadding({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: AppTheme.pageInsets, child: child);
  }
}
