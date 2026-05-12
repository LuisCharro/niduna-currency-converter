import 'package:flutter/material.dart';

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
  static const double radius = 12;
  static const double cardRadius = 16;
  static const double pillRadius = 20;
  static const List<BoxShadow> subtleShadow = <BoxShadow>[
    BoxShadow(color: Color(0x14285F3B), blurRadius: 10, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> floatingShadow = <BoxShadow>[
    BoxShadow(color: Color(0x10285F3B), blurRadius: 18, offset: Offset(0, 8)),
  ];

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

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Manrope',
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
    scaffoldBackgroundColor: const Color(0xFF171D14),
    fontFamily: 'Manrope',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF6F8EF),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFF6F8EF),
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1C2D14),
      elevation: 0,
      selectedItemColor: const Color(0xFF6F8C49),
      unselectedItemColor: const Color(0xFF88987A),
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
      color: const Color(0xFF3B5D24).withValues(alpha: 0.15),
      thickness: 0.5,
    ),
  );
}
