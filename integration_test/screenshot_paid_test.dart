import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/main.dart' as app;

/// Paid-layout capture: the same four-tab journey as screenshot_demo_test.dart
/// with Remove Ads owned, so banner space does not alter the main UI layout.
///
/// Run through the shared screenshots driver:
///   SCREEN_OUTPUT_DIR=/absolute/path/.tmp/screens/android/paid \
///   CAPTURE_TARGET_PATH=integration_test/screenshot_paid_test.dart \
///   ./.devtools/capture_android_screens.sh
Future<void> _seedRemoveAdsOwner() async {
  final prefs = await SharedPreferences.getInstance();
  const dark = bool.fromEnvironment('SCREENSHOT_DARK');

  await prefs.setBool('pref_dark_mode', dark);
  await prefs.setBool('entitlement_remove_ads_lifetime', true);
  await prefs.setBool('entitlement_charts_pro_lifetime', false);
  await prefs.setBool('entitlement_favorites_pro_lifetime', false);
  await prefs.setStringList('favorite_pairs', <String>[
    'USD-EUR',
    'USD-GBP',
    'USD-BTC',
  ]);
  await prefs.setBool('starter_favorites_seeded', true);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 5);

  Future<void> settleForCapture(
    WidgetTester tester, {
    required bool initialLaunch,
  }) async {
    await tester.pumpAndSettle(
      initialLaunch ? launchSettle : const Duration(milliseconds: 100),
    );
    // The tab shell uses a shared transition and can leave the previous tab
    // composited briefly on the Android surface after pumpAndSettle returns.
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('capture each bottom tab with Remove Ads owned', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
    await _seedRemoveAdsOwner();

    app.main();
    await settleForCapture(tester, initialLaunch: true);
    await binding.takeScreenshot('paid-01-convert');

    await tester.tap(find.text('Favorites'));
    await settleForCapture(tester, initialLaunch: false);
    await binding.takeScreenshot('paid-02-favorites');

    await tester.tap(find.text('Chart'));
    await settleForCapture(tester, initialLaunch: false);
    await binding.takeScreenshot('paid-03-chart');

    await tester.tap(find.text('Settings'));
    await settleForCapture(tester, initialLaunch: false);
    await binding.takeScreenshot('paid-04-settings');
  });
}
