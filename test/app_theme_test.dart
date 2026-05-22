import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';

void main() {
  test('canonical layout tokens match redesign spec', () {
    expect(AppTheme.pagePadding, 20);
    expect(AppTheme.sectionGap, 24);
    expect(AppTheme.rowMinHeight, 64);
    expect(AppTheme.pageInsets, const EdgeInsets.symmetric(horizontal: 20));
    expect(AppTheme.muted, const Color(0xFF5F6A58));
    expect(AppTheme.subtle, const Color(0xFF66745B));
    expect(AppTheme.containerHigh, const Color(0xFFF5EDEE));
  });
}
