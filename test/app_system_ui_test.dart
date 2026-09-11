import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark app surfaces request light Android system icons', () {
    final style = AppTheme.dark.appBarTheme.systemOverlayStyle;

    expect(style, isNotNull);
    expect(style!.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
  });

  test('light app surfaces request dark Android system icons', () {
    final style = AppTheme.light.appBarTheme.systemOverlayStyle;

    expect(style, isNotNull);
    expect(style!.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  });
}
