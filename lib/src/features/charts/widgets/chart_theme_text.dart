import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

abstract final class ChartThemeText {
  static TextStyle caption({Color? color}) =>
      AppTheme.caption.copyWith(color: color ?? AppTheme.muted);

  static TextStyle micro({Color? color}) =>
      AppTheme.micro.copyWith(color: color ?? AppTheme.muted);

  static TextStyle frauncesValue({Color? color, double size = 17}) =>
      TextStyle(
        fontFamily: 'Fraunces',
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? AppTheme.text,
        letterSpacing: -0.35,
      );
}
