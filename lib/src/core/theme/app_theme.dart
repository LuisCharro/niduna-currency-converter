import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color bg = Color(0xFFF8F9FA);
  static const Color text = Color(0xFF191C1D);
  static const Color muted = Color(0xFF5F5E5E);
  static const Color subtle = Color(0xFF717786);
  static const Color card = Colors.white;
  static const Color container = Color(0xFFEDEEEF);
  static const Color containerHigh = Color(0xFFE7E8E9);
  static const Color border = Color(0xFFE1E3E4);
  static const Color primary = Color(0xFF0058BC);
  static const double radius = 12;
  static const double cardRadius = 16;
  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(color: Color(0x10121212), blurRadius: 30, offset: Offset(0, 10)),
  ];

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: text,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: primary,
      unselectedItemColor: muted,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      type: BottomNavigationBarType.fixed,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF1A1C1E),
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE8E8E8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E2024),
      selectedItemColor: const Color(0xFF4A9EFF),
      unselectedItemColor: const Color(0xFF6B7080),
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      type: BottomNavigationBarType.fixed,
    ),
  );
}
