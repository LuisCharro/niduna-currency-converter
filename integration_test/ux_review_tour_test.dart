import 'dart:io' show Platform;

import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/main.dart' as app;
import 'package:currency_converter/src/shared/widgets/floating_pill_nav.dart';

/// UX review tour: walks a fresh free user through every main surface
/// (tabs, sheets, detail pages) and captures each one. Steps are
/// independent: a step that cannot find its target is logged and skipped so
/// one broken finder does not hide the rest of the tour.
///
/// Run on one or more emulators via `.devtools/capture_android_ux_tour.sh`
/// (SCREENSHOT_DARK=true for the dark variant, SCREENSHOT_PAID=true to
/// simulate all lifetime entitlements).
Future<void> _seedFreshUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setBool(
    'pref_dark_mode',
    const bool.fromEnvironment('SCREENSHOT_DARK'),
  );
  if (const bool.fromEnvironment('SCREENSHOT_PAID')) {
    await prefs.setBool('entitlement_remove_ads_lifetime', true);
    await prefs.setBool('entitlement_charts_pro_lifetime', true);
    await prefs.setBool('entitlement_favorites_pro_lifetime', true);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const settle = Duration(seconds: 4);
  final skipped = <String>[];

  testWidgets('ux review tour', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
    await _seedFreshUser();

    Finder nav(IconData icon) => find.descendant(
      of: find.byType(FloatingPillNav),
      matching: find.byIcon(icon),
    );

    Future<void> settleFor([Duration d = settle]) async {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(d);
    }

    Future<void> shot(String name) async {
      await settleFor(const Duration(seconds: 2));
      await binding.takeScreenshot(name);
    }

    Future<void> dismissSheet() async {
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.maybePop();
      await settleFor(const Duration(seconds: 2));
    }

    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
      } catch (e) {
        skipped.add('$name: $e'.split('\n').first);
        // ignore: avoid_print
        print('UX_TOUR_SKIP $name: $e');
        await dismissSheet();
      }
    }

    app.main();
    await settleFor(const Duration(seconds: 8));
    await shot('01-convert');

    await step('02-rates-info', () async {
      await tester.tap(find.byIcon(Icons.info_outline_rounded).first);
      await shot('02-rates-info-sheet');
      await dismissSheet();
    });

    await step('03-amount', () async {
      await tester.tap(find.byKey(const Key('convert_amount_field')));
      await shot('03-amount-keypad');
      await dismissSheet();
    });

    await step('04-lens', () async {
      final row = find.byKey(const Key('convert_row_EUR')).evaluate().isEmpty
          ? find
                .byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key! as ValueKey<String>).value.startsWith(
                        'convert_row_',
                      ),
                )
                .first
          : find.byKey(const Key('convert_row_EUR'));
      // The row opens the lens after an 800 ms "charge" hold.
      final gesture = await tester.startGesture(tester.getCenter(row));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await gesture.up();
      await shot('04-conversion-lens');
      await dismissSheet();
    });

    await step('05-swipe', () async {
      final row = find
          .byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('convert_row_'),
          )
          .first;
      await tester.drag(row, const Offset(-220, 0));
      await shot('05-row-swipe-actions');
      await tester.drag(row, const Offset(220, 0));
      await settleFor();
    });

    await step('06-base-picker', () async {
      await tester.tap(
        find.byKey(const Key('open_base_currency_picker')).first,
      );
      await shot('06-base-picker');
      await dismissSheet();
    });

    await step('07-visible-picker', () async {
      await tester.tap(find.byKey(const Key('open_currency_picker')));
      await shot('07-visible-currencies-picker');
      await dismissSheet();
    });

    await step('08-favorites', () async {
      await tester.tap(nav(Icons.star_rounded));
      await shot('08-favorites');
    });

    await step('08b-favorites-swipe', () async {
      // The second favorites row (first after the hero card) is the
      // USD → GBP starter pair; swipe it left to reveal Remove.
      final row = find.byKey(const ValueKey<String>('USD-GBP'));
      await tester.drag(row, const Offset(-200, 0));
      await shot('08b-favorites-swipe');
      await tester.drag(row, const Offset(200, 0));
      await settleFor();
    });

    await step('09-charts', () async {
      await tester.tap(nav(Icons.show_chart_rounded));
      await settleFor(const Duration(seconds: 8));
      await shot('09-charts');
    });

    await step('10-chart-touch', () async {
      final box = tester.getRect(find.byType(LineChart));
      await tester.tapAt(Offset(box.left + box.width * 0.6, box.center.dy));
      await shot('10-chart-touch');
    });

    await step('11-chart-picker', () async {
      await tester.tap(find.byKey(const Key('charts_pair_quote')));
      await shot('11-chart-quote-picker');
      await dismissSheet();
    });

    await step('12-settings', () async {
      await tester.tap(nav(Icons.settings_rounded));
      await shot('12-settings-top');
    });

    await step('13-settings-bottom', () async {
      await tester.drag(find.byType(ListView).last, const Offset(0, -2000));
      await shot('13-settings-bottom');
    });

    await step('14-data-privacy', () async {
      await tester.drag(find.byType(ListView).last, const Offset(0, 2000));
      await settleFor();
      await tester.scrollUntilVisible(
        find.text('Data & privacy'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Data & privacy'));
      await settleFor();
      await shot('14-data-privacy');
      await dismissSheet();
    });

    await step('15-settings-base-picker', () async {
      await tester.drag(find.byType(ListView).last, const Offset(0, 2000));
      await settleFor();
      await tester.tap(find.text('Default base currency').first);
      await shot('15-settings-base-picker');
      await dismissSheet();
    });

    await step('16-convert-return', () async {
      await tester.tap(nav(Icons.swap_horiz_rounded));
      await shot('16-convert-return');
    });

    // ignore: avoid_print
    print('UX_TOUR_DONE skipped=${skipped.length}\n${skipped.join('\n')}');
  });
}
