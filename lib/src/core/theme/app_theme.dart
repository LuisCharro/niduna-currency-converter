import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_text_styles.dart';

export 'app_decorations.dart';
export 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const Color bg = Color(0xFFF5F4F0);
  static const text = Color(0xFF1C1F18);
  static const muted = Color(0xFF6B7560);
  static const subtle = Color(0xFF8A9178);
  static const card = Color(0xFFFFFFFF);
  static const container = Color(0xFFFFFFFF);
  static const containerHigh = Color(0xFFF0EDE9);
  static const border = Color(0xFF3B5D24);
  static const primary = Color(0xFF285F3B);
  static const trendUp = Color(0xFF6F8C49);
  static const trendDown = Color(0xFFDC6543);
  static const greenBadge = Color(0xFFEDF5EB);
  static const greenBadgeText = Color(0xFF3D6E2C);
  static const Color coralSurface = Color(0xFFFDF0EC);
  static const Color coralInk = Color(0xFFB54E48);

  static const double space1 = 4, space2 = 8, space3 = 12, space4 = 16;
  static const double space5 = 20, space6 = 24, space7 = 32, space8 = 40;
  static Color instrumentFill([double alpha = 0.62]) =>
      containerHigh.withValues(alpha: alpha);
  static Color instrumentBorder([double alpha = 0.15]) =>
      border.withValues(alpha: alpha);
  static const double pagePadding = 20;
  static const EdgeInsets pageInsets = EdgeInsets.symmetric(
    horizontal: pagePadding,
  );
  static const double sectionGap = 24, navOuterRadius = 32, radius = 12;
  static const double cardRadius = 16, pillRadius = 20, rowMinHeight = 64;
  static const double floatingNavHeight = 64, floatingNavBottomOffset = 0;
  static const double bottomDockGap = 8;
  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionMedium = Duration(milliseconds: 180);
  static const Duration motionSlow = Duration(milliseconds: 240);
  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveStandard = Curves.easeInOutCubic;

  static const TextStyle display = AppTextStyles.display;
  static const TextStyle heading = AppTextStyles.heading;
  static const TextStyle body = AppTextStyles.body;
  static const TextStyle caption = AppTextStyles.caption;
  static const TextStyle micro = AppTextStyles.micro;
  static TextStyle screenTitleStyle(BuildContext context) =>
      AppTextStyles.screenTitleStyle(context);
  static const TextStyle screenTitleFraunces =
      AppTextStyles.screenTitleFraunces;
  static const TextStyle settingsGroupTitle =
      AppTextStyles.settingsGroupTitle;
  static TextStyle settingsGroupTitleStyle(BuildContext context) =>
      AppTextStyles.settingsGroupTitleStyle(context);
  static const TextStyle settingsTileTitle =
      AppTextStyles.settingsTileTitle;
  static TextStyle settingsTileTitleStyle(BuildContext context) =>
      AppTextStyles.settingsTileTitleStyle(context);
  static const TextStyle supportingText = AppTextStyles.supportingText;
  static TextStyle supportingTextStyle(BuildContext context) =>
      AppTextStyles.supportingTextStyle(context);
  static TextStyle heroAmountStyle(BuildContext context) =>
      AppTextStyles.heroAmountStyle(context);
  static const TextStyle heroAmount = AppTextStyles.heroAmount;
  static TextStyle heroAmountCompactStyle(BuildContext context) =>
      AppTextStyles.heroAmountCompactStyle(context);
  static const TextStyle heroAmountCompact = AppTextStyles.heroAmountCompact;
  static const List<double> heroAmountSizes = AppTextStyles.heroAmountSizes;
  static TextStyle pairTitleStyle(BuildContext context) =>
      AppTextStyles.pairTitleStyle(context);
  static const TextStyle pairTitleFraunces =
      AppTextStyles.pairTitleFraunces;
  static TextStyle metricValueStyle(BuildContext context) =>
      AppTextStyles.metricValueStyle(context);
  static const TextStyle metricValue = AppTextStyles.metricValue;
  static const TextStyle metricDelta = AppTextStyles.metricDelta;
  static TextStyle sectionLabelStyle(BuildContext context) =>
      AppTextStyles.sectionLabelStyle(context);
  static const TextStyle sectionLabel = AppTextStyles.sectionLabel;
  static TextStyle heroAmountFor(BuildContext context) =>
      AppTextStyles.heroAmountFor(context);

  static List<BoxShadow> subtleShadowFor(BuildContext context) =>
      AppDecorations.subtleShadowFor(context);
  static const List<BoxShadow> subtleShadow = AppDecorations.subtleShadow;
  static List<BoxShadow> floatingShadowFor(BuildContext context) =>
      AppDecorations.floatingShadowFor(context);
  static const List<BoxShadow> floatingShadow = AppDecorations.floatingShadow;
  static double tabScrollBottomPadding(BuildContext context) =>
      AppDecorations.tabScrollBottomPadding(context);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Manrope',
    extensions: [AppColors.light],
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: text,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: container,
      elevation: 0,
      selectedItemColor: primary,
      unselectedItemColor: muted,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: DividerThemeData(
      color: border.withValues(alpha: 0.15),
      thickness: 0.5,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    chipTheme: ChipThemeData(
      selectedColor: primary,
      labelStyle: TextStyle(color: text),
      side: const BorderSide(color: Colors.transparent),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pillRadius),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.dark.bg,
    fontFamily: 'Manrope',
    extensions: [AppColors.dark],
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dark.primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.dark.text,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.dark.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark.container,
      elevation: 0,
      selectedItemColor: AppColors.dark.primary,
      unselectedItemColor: AppColors.dark.muted,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.dark.border.withValues(alpha: 0.15),
      thickness: 0.5,
    ),
  );
}
