import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:currency_converter/main.dart' as app;

/// Demo capture: launches the app and photographs each bottom tab.
/// Run through the screenshots driver so images are saved to disk:
///   .devtools/capture_android_screens.sh with
///   CAPTURE_TARGET_PATH=integration_test/screenshot_demo_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 5);

  testWidgets('capture each bottom tab', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);
    await binding.takeScreenshot('01-convert');

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02-favorites');

    await tester.tap(find.text('Chart'));
    await tester.pumpAndSettle(launchSettle);
    await binding.takeScreenshot('03-chart');

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04-settings');
  });
}
