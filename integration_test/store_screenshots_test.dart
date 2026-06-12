import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/main.dart' as app;

/// Store screenshot capture: same flow as the visual audit, but with the
/// Remove Ads entitlement enabled so captures are ad-free (a real product
/// state - what paying users see). Run through the screenshots driver:
///   CAPTURE_TARGET_PATH=integration_test/store_screenshots_test.dart \
///     SCREEN_OUTPUT_DIR=.tmp/screens/store-raw \
///     .devtools/capture_android_screens.sh
/// Then compose: .devtools/compose_store_screenshots.sh
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 6);
  const navSettle = Duration(seconds: 3);

  Future<void> shoot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle(navSettle);
    await binding.takeScreenshot(name);
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle(navSettle);
  }

  Future<void> captureAllTabs(WidgetTester tester, String prefix) async {
    await tapTab(tester, 'Convert');
    await shoot(tester, '$prefix-01-convert');
    await tester.tap(find.text('Add currencies'));
    await shoot(tester, '$prefix-02-picker');
    await tester.tapAt(const Offset(200, 50));
    await tester.pumpAndSettle(navSettle);

    await tapTab(tester, 'Favorites');
    await shoot(tester, '$prefix-03-favorites');

    await tapTab(tester, 'Chart');
    await tester.pumpAndSettle(launchSettle);
    await shoot(tester, '$prefix-04-chart');
  }

  testWidgets('capture ad-free store screenshots', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    // Remove Ads entitlement: captures show the paid, ad-free experience.
    // Also force light mode so the light/dark capture order is
    // deterministic regardless of what a previous session left behind.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('entitlement_remove_ads_lifetime', true);
    await prefs.setBool('pref_dark_mode', false);

    app.main();
    await tester.pumpAndSettle(launchSettle);

    await captureAllTabs(tester, 'light');

    await tapTab(tester, 'Settings');
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle(navSettle);

    await captureAllTabs(tester, 'dark');

    // Restore defaults for subsequent runs.
    await tapTab(tester, 'Settings');
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle(navSettle);
    await prefs.setBool('entitlement_remove_ads_lifetime', false);
  });
}
