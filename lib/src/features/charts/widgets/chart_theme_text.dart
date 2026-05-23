import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

abstract final class ChartThemeText {
  static TextStyle caption(BuildContext context, {Color? color}) =>
      AppTheme.caption.copyWith(color: color ?? AppColors.of(context).muted);

  static TextStyle micro(BuildContext context, {Color? color}) =>
      AppTheme.micro.copyWith(color: color ?? AppColors.of(context).muted);

  static TextStyle frauncesValue(BuildContext context, {Color? color, double size = 17}) =>
      TextStyle(
        fontFamily: 'Fraunces',
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.of(context).text,
        letterSpacing: -0.35,
      );
}
