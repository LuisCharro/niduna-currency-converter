import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const Color bg = Color(0xFFF6F8EF);
  static const text = Color(0xFF171D14);
  static const muted = Color(0xFF5F6A58);
  static const subtle = Color(0xFF66745B);
  static const card = Color(0xFFFFFFFF);
  static const container = Color(0xFFFFF9EC);
  static const containerHigh = Color(0xFFF5EDEE);
  static const border = Color(0xFF3B5D24);
  static const primary = Color(0xFF285F3B);
  static const trendUp = Color(0xFF6F8C49);
  static const trendDown = Color(0xFFDC6543);
  static const greenBadge = Color(0xFFEDF5EB);
  static const greenBadgeText = Color(0xFF3D6E2C);
  static const Color coralSurface = Color(0xFFFDF0EC);
  static const Color coralInk = Color(0xFFB54E48);

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;
  static const double space8 = 40;

  static Color instrumentFill([double alpha = 0.62]) =>
      containerHigh.withValues(alpha: alpha);

  static Color instrumentBorder([double alpha = 0.15]) =>
      border.withValues(alpha: alpha);

  static const double pagePadding = 20;
  static const EdgeInsets pageInsets = EdgeInsets.symmetric(
    horizontal: pagePadding,
  );
  static const double sectionGap = 24;
  static const double navOuterRadius = 32;

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
    color: text,
  );

  static const TextStyle settingsGroupTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: text,
  );

  static TextStyle settingsGroupTitleStyle(BuildContext context) {
    return settingsGroupTitle.copyWith(color: AppColors.of(context).text);
  }

  static const TextStyle settingsTileTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: text,
  );

  static TextStyle settingsTileTitleStyle(BuildContext context) {
    return settingsTileTitle.copyWith(color: AppColors.of(context).text);
  }

  static const TextStyle supportingText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.32,
    color: muted,
  );

  static TextStyle supportingTextStyle(BuildContext context) {
    return supportingText.copyWith(color: AppColors.of(context).muted);
  }

  static const double radius = 12;
  static const double cardRadius = 16;
  static const double pillRadius = 20;
  static const double rowMinHeight = 64;
  static const double floatingNavHeight = 64;
  static const double floatingNavBottomOffset = 0;
  static const double bottomDockGap = 8;

  static List<BoxShadow> subtleShadowFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return <BoxShadow>[
      BoxShadow(
        color: isDark ? const Color(0x30FFFFFF) : const Color(0x0F285F3B),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static const List<BoxShadow> subtleShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0F285F3B), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> floatingShadowFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return <BoxShadow>[
      BoxShadow(
        color: isDark ? const Color(0x40FFFFFF) : const Color(0x18285F3B),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static const List<BoxShadow> floatingShadow = <BoxShadow>[
    BoxShadow(color: Color(0x18285F3B), blurRadius: 22, offset: Offset(0, 10)),
  ];

  static double tabScrollBottomPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom +
        floatingNavHeight +
        floatingNavBottomOffset +
        bottomDockGap +
        12;
  }

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

  static const body = TextStyle(
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
    color: text,
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
    color: text,
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
    color: text,
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
    color: text,
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
    color: muted,
  );

  static TextStyle heroAmountFor(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return scale >= 1.3
        ? heroAmountCompactStyle(context)
        : heroAmountStyle(context);
  }

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Manrope',
    extensions: [AppColors.light],
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
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
