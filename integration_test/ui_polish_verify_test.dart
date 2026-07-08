import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/main.dart' as app;
import 'package:currency_converter/src/shared/widgets/floating_pill_nav.dart';

/// Verify captures for the 2026-07-08 polish pass: empty Favorites state
/// (centered, no clipping), Settings (switch theming, single data tile),
/// and the merged Data & privacy page. Run via
/// `CAPTURE_TARGET_PATH=integration_test/ui_polish_verify_test.dart
///  ./.devtools/capture_android_screens.sh`
/// (set SCREENSHOT_DARK=true for the dark variant).
Future<void> _seedPaidUserWithoutFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  const dark = bool.fromEnvironment('SCREENSHOT_DARK');
  await prefs.setBool('pref_dark_mode', dark);
  await prefs.setBool('entitlement_remove_ads_lifetime', true);
  await prefs.setBool('entitlement_charts_pro_lifetime', true);
  await prefs.setBool('entitlement_favorites_pro_lifetime', true);
  await prefs.setStringList('favorite_pairs', <String>[]);
  // Keep the list truly empty (app seeds starter pairs on first run) and
  // leave one switch off so the unselected switch styling is visible.
  await prefs.setBool('starter_favorites_seeded', true);
  await prefs.setBool('pref_refresh_on_open', false);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 5);

  testWidgets('capture polish verification screens', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
    await _seedPaidUserWithoutFavorites();

    app.main();
    await tester.pumpAndSettle(launchSettle);

    Finder navIcon(IconData icon) => find.descendant(
          of: find.byType(FloatingPillNav),
          matching: find.byIcon(icon),
        );

    await tester.tap(navIcon(Icons.star_rounded));
    await tester.pumpAndSettle(launchSettle);
    await binding.takeScreenshot('v1-favorites-empty');

    await tester.tap(navIcon(Icons.settings_rounded));
    await tester.pumpAndSettle(launchSettle);
    await binding.takeScreenshot('v2-settings');

    await tester.tap(find.text('Data & privacy'));
    await tester.pumpAndSettle(launchSettle);
    // Extra settle: the previous capture caught the route mid-transition.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(launchSettle);
    await binding.takeScreenshot('v3-data-privacy');
  });
}
