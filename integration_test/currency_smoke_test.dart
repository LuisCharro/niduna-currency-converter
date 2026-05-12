import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:currency_converter/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 5);

  testWidgets('app launches and shows Convert tab', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    expect(find.text('Convert'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('bottom navigation shows all 3 tabs', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    expect(find.text('Convert'), findsWidgets);
    expect(find.text('Chart'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('navigate to Chart tab', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    await tester.tap(find.text('Chart'));
    await tester.pumpAndSettle();

    expect(find.text('Chart'), findsWidgets);
  });

  testWidgets('navigate to Settings tab', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
  });
}
