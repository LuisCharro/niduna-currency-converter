import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const Color _text = Color(0xFF1C1F18);
  static const Color _muted = Color(0xFF6B7560);

  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static TextStyle screenTitleStyle(BuildContext context) {
    final colors = AppColors.of(context);
    return const TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 24,
      fontWeight: FontWeight.w800,
      height: 1.08,
      letterSpacing: -0.25,
    ).copyWith(color: colors.text);
  }

  static const TextStyle screenTitleFraunces = TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.08,
    letterSpacing: -0.25,
    color: _text,
  );

  static const TextStyle settingsGroupTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: _text,
  );

  static TextStyle settingsGroupTitleStyle(BuildContext context) {
    return settingsGroupTitle.copyWith(color: AppColors.of(context).text);
  }

  static const TextStyle settingsTileTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: _text,
  );

  static TextStyle settingsTileTitleStyle(BuildContext context) {
    return settingsTileTitle.copyWith(color: AppColors.of(context).text);
  }

  static const TextStyle supportingText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.32,
    color: _muted,
  );

  static TextStyle supportingTextStyle(BuildContext context) {
    return supportingText.copyWith(color: AppColors.of(context).muted);
  }

  static TextStyle heroAmountStyle(BuildContext context) {
    final colors = AppColors.of(context);
    return const TextStyle(
      fontSize: 50,
      fontWeight: FontWeight.w800,
      height: 1.05,
      letterSpacing: -1,
    ).copyWith(color: colors.text);
  }

  static const TextStyle heroAmount = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -1,
    color: _text,
  );

  static TextStyle heroAmountCompactStyle(BuildContext context) {
    final colors = AppColors.of(context);
    return const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      height: 1.05,
      letterSpacing: -0.6,
    ).copyWith(color: colors.text);
  }

  static const TextStyle heroAmountCompact = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -0.6,
    color: _text,
  );

  static const List<double> heroAmountSizes = [50.0, 44.0, 38.0, 32.0];

  static TextStyle pairTitleStyle(BuildContext context) {
    final colors = AppColors.of(context);
    return const TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.05,
    ).copyWith(color: colors.text);
  }

  static const TextStyle pairTitleFraunces = TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.05,
    color: _text,
  );

  static TextStyle metricValueStyle(BuildContext context) {
    final colors = AppColors.of(context);
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ).copyWith(color: colors.text);
  }

  static const TextStyle metricValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: _text,
  );

  static const TextStyle metricDelta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static TextStyle sectionLabelStyle(BuildContext context) {
    final colors = AppColors.of(context);
    return const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.9,
      height: 1.2,
    ).copyWith(color: colors.muted);
  }

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
    height: 1.2,
    color: _muted,
  );

  static TextStyle heroAmountFor(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return scale >= 1.3
        ? heroAmountCompactStyle(context)
        : heroAmountStyle(context);
  }
}
