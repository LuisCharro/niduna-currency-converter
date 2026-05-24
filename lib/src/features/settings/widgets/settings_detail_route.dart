import 'package:flutter/material.dart';

Route<T> buildSettingsDetailRoute<T>({
  required WidgetBuilder builder,
  required ThemeData theme,
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        Theme(data: theme, child: builder(context)),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(offset), child: child);
    },
  );
}
