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

    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Niduna Convert'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('bottom navigation shows all 4 tabs', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Charts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('navigate to Favorites tab', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsWidgets);
  });

  testWidgets('navigate to Charts tab', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    await tester.tap(find.text('Charts'));
    await tester.pumpAndSettle();

    expect(find.text('Charts'), findsWidgets);
  });

  testWidgets('navigate to Settings tab', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    app.main();
    await tester.pumpAndSettle(launchSettle);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('App settings'), findsOneWidget);
  });
}
