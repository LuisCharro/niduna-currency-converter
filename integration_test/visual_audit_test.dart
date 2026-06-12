import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:currency_converter/main.dart' as app;

/// Visual audit capture: photographs every main screen in light and dark
/// mode. Run through the screenshots driver:
///   CAPTURE_TARGET_PATH=integration_test/visual_audit_test.dart \
///     .devtools/capture_android_screens.sh
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 6);
  const navSettle = Duration(seconds: 3);

  Future<void> shoot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle(navSettle);
    await binding.takeScreenshot(name);
  }

  // Nav labels also appear as screen titles; the nav bar instance is last.
  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle(navSettle);
  }

  Future<void> captureAllTabs(WidgetTester tester, String prefix) async {
    // Convert tab and the currency picker modal.
    await tapTab(tester, 'Convert');
    await shoot(tester, '$prefix-01-convert');
    await tester.tap(find.text('Add currencies'));
    await shoot(tester, '$prefix-02-picker');
    await tester.tapAt(const Offset(200, 50)); // dismiss modal
    await tester.pumpAndSettle(navSettle);

    await tapTab(tester, 'Favorites');
    await shoot(tester, '$prefix-03-favorites');

    await tapTab(tester, 'Chart');
    await tester.pumpAndSettle(launchSettle);
    await shoot(tester, '$prefix-04-chart');

    await tapTab(tester, 'Settings');
    await shoot(tester, '$prefix-05-settings-top');
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, -1600),
      2400,
    );
    await shoot(tester, '$prefix-06-settings-bottom');
    // Back to top so the next pass starts in a known state.
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, 1600),
      2400,
    );
    await tester.pumpAndSettle(navSettle);
  }

  testWidgets('capture all screens light and dark', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    await captureAllTabs(tester, 'light');

    // Toggle dark mode: first switch on the Settings screen is "Dark mode".
    await tapTab(tester, 'Settings');
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle(navSettle);

    await captureAllTabs(tester, 'dark');

    // Restore light mode so repeated runs start consistently.
    await tapTab(tester, 'Settings');
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle(navSettle);
  });
}
