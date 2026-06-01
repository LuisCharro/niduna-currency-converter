import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/rewarded_ad_service_stub.dart';
import 'package:currency_converter/src/core/preferences/app_preferences.dart';
import 'package:currency_converter/src/core/theme/app_colors.dart';
import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/domain/chart_range.dart';
import 'package:currency_converter/src/features/charts/widgets/range_selector.dart';
import 'package:currency_converter/src/features/settings/settings_controller.dart';
import 'package:currency_converter/src/features/settings/widgets/decimal_places_tile.dart';

void main() {
  // RangeSelector ----------------------------------------------------------------

  testWidgets(
    'RangeSelector: locked range shows a filled Icons.lock (not outline)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RangeSelector(
            selected: ChartRange.oneMonth,
            onChanged: _noop,
            canUseLockedRanges: false,
            includesCrypto: false,
          ),
        ),
      );
      // 1H/6H/1D are locked. Find the one rendered in the first position.
      final lockedIcons = find.byIcon(Icons.lock);
      expect(
        lockedIcons,
        findsAtLeastNWidgets(3),
        reason: 'Locked ranges (1H, 6H, 1D) must all show a filled lock icon',
      );
      // Make sure no outline version is used.
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    },
  );

  testWidgets(
    'RangeSelector: selected range gets a primary-tinted background and border',
    (tester) async {
      const selected = ChartRange.oneMonth;
      await tester.pumpWidget(
        _wrap(
          const RangeSelector(
            selected: selected,
            onChanged: _noop,
            canUseLockedRanges: false,
            includesCrypto: false,
          ),
        ),
      );
      // Find the AnimatedContainer holding the selected label.
      final selectedText = find.text('1M');
      expect(selectedText, findsOneWidget);
      final containerFinder = find.ancestor(
        of: selectedText,
        matching: find.byType(AnimatedContainer),
      );
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<AnimatedContainer>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNot(Colors.transparent));
      // Background should be derived from primary, not the plain card color.
      final light = AppColors.light;
      final expectedBg = light.primary.withValues(alpha: .10);
      expect(decoration.color, equals(expectedBg));
      // Border should also use primary.
      final border = decoration.border! as Border;
      expect(border.top.color, equals(light.primary.withValues(alpha: .35)));
    },
  );

  testWidgets(
    'RangeSelector: unselected unlocked range has no background tint',
    (tester) async {
      const selected = ChartRange.oneMonth;
      await tester.pumpWidget(
        _wrap(
          const RangeSelector(
            selected: selected,
            onChanged: _noop,
            canUseLockedRanges: false,
            includesCrypto: false,
          ),
        ),
      );
      // 1W and 3M are unlocked + unselected.
      final oneWeekText = find.text('1W');
      final containerFinder = find.ancestor(
        of: oneWeekText,
        matching: find.byType(AnimatedContainer),
      );
      final container = tester.widget<AnimatedContainer>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
    },
  );

  // DecimalPlacesTile ------------------------------------------------------------

  group('DecimalPlacesTile', () {
    late AppPreferences preferences;
    late SettingsController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'pref_decimal_places': 2});
      final prefs = await SharedPreferences.getInstance();
      preferences = AppPreferences(prefs);
      final monetization = MonetizationController(
        prefs,
        adService: RewardedAdServiceStub(),
      );
      controller = SettingsController(
        preferences: preferences,
        monetization: monetization,
        onClearCache: () {},
      );
    });

    testWidgets(
      'unselected buttons in LIGHT mode use container bg + low-alpha border',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: DecimalPlacesTile(controller: controller),
            ),
          ),
        );
        final decoration = _decorationFor(tester, '3');
        final light = AppColors.light;
        expect(decoration.color, equals(light.container));
        final border = decoration.border! as Border;
        expect(
          border.top.color,
          equals(light.border.withValues(alpha: .35)),
        );
      },
    );

    testWidgets(
      'unselected buttons in DARK mode use containerHigh bg + full border',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: DecimalPlacesTile(controller: controller),
            ),
          ),
        );
        final decoration = _decorationFor(tester, '3');
        final dark = AppColors.dark;
        expect(decoration.color, equals(dark.containerHigh));
        final border = decoration.border! as Border;
        expect(border.top.color, equals(dark.border));
      },
    );

    testWidgets(
      'selected button (2) uses primary bg + primary border in both modes',
      (tester) async {
        for (final theme in [AppTheme.light, AppTheme.dark]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: DecimalPlacesTile(controller: controller),
              ),
            ),
          );
          final decoration = _decorationFor(tester, '2');
          final colors = AppColors.of(_contextOf(tester));
          expect(decoration.color, equals(colors.primary));
          final border = decoration.border! as Border;
          expect(border.top.color, equals(colors.primary));
        }
      },
    );
  });
}

// ---- helpers ----

void _noop(ChartRange _) {}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  );
}

BoxDecoration _decorationFor(WidgetTester tester, String label) {
  final text = find.text(label);
  expect(text, findsOneWidget);
  final container = find.ancestor(of: text, matching: find.byType(Container));
  expect(container, findsOneWidget);
  final widget = tester.widget<Container>(container);
  return widget.decoration! as BoxDecoration;
}

BuildContext _contextOf(WidgetTester tester) {
  return tester.element(find.byType(DecimalPlacesTile));
}
