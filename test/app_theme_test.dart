import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';

void main() {
  test('canonical layout tokens match redesign spec', () {
    expect(AppTheme.pagePadding, 20);
    expect(AppTheme.sectionGap, 24);
    expect(AppTheme.rowMinHeight, 64);
    expect(AppTheme.pageInsets, const EdgeInsets.symmetric(horizontal: 20));
    expect(AppTheme.muted, const Color(0xFF6B7560));
    expect(AppTheme.subtle, const Color(0xFF8A9178));
    expect(AppTheme.containerHigh, const Color(0xFFF0EDE9));
    expect(AppTheme.coralSurface, const Color(0xFFFDF0EC));
    expect(AppTheme.coralInk, const Color(0xFFB54E48));
    expect(AppTheme.space5, AppTheme.pagePadding);
    expect(AppTheme.heroAmount.fontSize, 50);
    expect(AppTheme.heroAmountCompact.fontSize, 40);
    expect(AppTheme.pairTitleFraunces.fontFamily, 'Fraunces');
    expect(AppTheme.motionFast, const Duration(milliseconds: 120));
    expect(AppTheme.motionMedium, const Duration(milliseconds: 180));
    expect(AppTheme.motionSlow, const Duration(milliseconds: 240));
  });

  test('motion tokens use the planned shell curves', () {
    expect(AppTheme.curveEnter, Curves.easeOutCubic);
    expect(AppTheme.curveExit, Curves.easeInCubic);
    expect(AppTheme.curveStandard, Curves.easeInOutCubic);
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
