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
    expect(AppTheme.coralSurface, const Color(0xFFFDF0EC));
    expect(AppTheme.coralInk, const Color(0xFFB54E48));
    expect(AppTheme.space5, AppTheme.pagePadding);
    expect(AppTheme.heroAmount.fontSize, 50);
    expect(AppTheme.heroAmountCompact.fontSize, 40);
    expect(AppTheme.pairTitleFraunces.fontFamily, 'Fraunces');
  });

  test('settings typography is subordinate to chart hero type', () {
    expect(AppTheme.screenTitleFraunces.fontSize, 24);
    expect(AppTheme.settingsGroupTitle.fontFamily, isNot('Fraunces'));
    expect(AppTheme.settingsGroupTitle.fontSize, lessThan(20));
    expect(AppTheme.settingsTileTitle.fontSize, 15);
    expect(AppTheme.supportingText.fontSize, 13);
  });

  testWidgets('heroAmountFor uses compact style at text scale 1.3', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Builder(
            builder: (context) {
              final style = AppTheme.heroAmountFor(context);
              expect(style.fontSize, 40);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  });
}
