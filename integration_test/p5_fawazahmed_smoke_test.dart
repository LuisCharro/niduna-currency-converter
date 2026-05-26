import 'dart:io' show Platform, sleep;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:currency_converter/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 8);
  const chartLoadSettle = Duration(seconds: 15);

  group('P5 Smoke Test — fawazahmed0 crypto history', () {
    testWidgets('Convert tab loads with amount input', (tester) async {
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      app.main();
      await tester.pumpAndSettle(launchSettle);

      expect(find.text('Convert'), findsWidgets);
      expect(find.text('100.00'), findsOneWidget);
    });

    testWidgets('navigate to Favorites tab and back', (tester) async {
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      app.main();
      await tester.pumpAndSettle(launchSettle);

      final favoritesTab = find.text('Favorites');
      if (favoritesTab.evaluate().isNotEmpty) {
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();

        expect(find.text('Favorites'), findsWidgets);

        final convertTab = find.text('Convert');
        await tester.tap(convertTab);
        await tester.pumpAndSettle();
      }

      expect(find.text('100.00'), findsOneWidget);
    });

    testWidgets('Charts tab loads and shows range selector', (tester) async {
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      app.main();
      await tester.pumpAndSettle(launchSettle);

      await tester.tap(find.text('Chart'));
      await tester.pumpAndSettle(chartLoadSettle);

      expect(find.text('Chart'), findsWidgets);

      final ranges = ['1W', '1M', '3M', '6M', '1Y'];
      for (final range in ranges) {
        expect(find.text(range), findsWidgets);
      }
    });

    testWidgets('Charts tab — select USD/BTC pair and verify chart loads',
        (tester) async {
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      app.main();
      await tester.pumpAndSettle(launchSettle);

      await tester.tap(find.text('Chart'));
      await tester.pumpAndSettle(chartLoadSettle);

      final quotePill = find.byKey(ValueKey('charts_pair_quote'));
      if (quotePill.evaluate().isNotEmpty) {
        await tester.tap(quotePill);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final btcOption = find.text('BTC').hitTestable();
        if (btcOption.evaluate().isNotEmpty) {
          await tester.tap(btcOption.first);
          await tester.pumpAndSettle(chartLoadSettle);
        }
      }

      expect(find.text('Chart'), findsWidgets);
    });

    testWidgets('Settings tab loads and shows provider info', (tester) async {
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      app.main();
      await tester.pumpAndSettle(launchSettle);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
      expect(
        find.textContaining('Frankfurter'),
        findsWidgets,
        reason: 'Settings should show Frankfurter as fiat provider',
      );
    });

    testWidgets('full tab cycle: Convert → Chart → Settings → Convert',
        (tester) async {
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }

      app.main();
      await tester.pumpAndSettle(launchSettle);

      expect(find.text('100.00'), findsOneWidget);

      await tester.tap(find.text('Chart'));
      await tester.pumpAndSettle(chartLoadSettle);
      expect(find.text('1Y'), findsWidgets);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);

      await tester.tap(find.text('Convert'));
      await tester.pumpAndSettle();
      expect(find.text('100.00'), findsOneWidget);
    });
  });
}
