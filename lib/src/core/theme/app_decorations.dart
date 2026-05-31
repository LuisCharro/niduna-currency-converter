import 'package:flutter/material.dart';

class AppDecorations {
  AppDecorations._();

  static const double _floatingNavHeight = 64;
  static const double _floatingNavBottomOffset = 0;
  static const double _bottomDockGap = 8;

  static List<BoxShadow> subtleShadowFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return <BoxShadow>[
      BoxShadow(
        color: isDark
            ? const Color(0x30FFFFFF)
            : const Color(0x1A285F3B),
        blurRadius: isDark ? 8 : 6,
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
        color: isDark
            ? const Color(0x40FFFFFF)
            : const Color(0x22285F3B),
        blurRadius: isDark ? 22 : 16,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static const List<BoxShadow> floatingShadow = <BoxShadow>[
    BoxShadow(color: Color(0x18285F3B), blurRadius: 22, offset: Offset(0, 10)),
  ];

  static double tabScrollBottomPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom +
        _floatingNavHeight +
        _floatingNavBottomOffset +
        _bottomDockGap +
        12;
  }
}
