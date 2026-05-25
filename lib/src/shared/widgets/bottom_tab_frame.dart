import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class BottomTabFrame extends StatelessWidget {
  const BottomTabFrame({required this.body, this.footer, super.key});

  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final footerInset =
        MediaQuery.paddingOf(context).bottom +
        AppTheme.floatingNavHeight +
        AppTheme.floatingNavBottomOffset +
        AppTheme.bottomDockGap;

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Expanded(child: body),
          if (footer != null) footer! else SizedBox(height: footerInset),
        ],
      ),
    );
  }
}
