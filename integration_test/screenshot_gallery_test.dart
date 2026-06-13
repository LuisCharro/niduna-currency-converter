import 'dart:io' show Platform;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/main.dart' as app;
import 'package:currency_converter/src/shared/widgets/floating_pill_nav.dart';

Future<void> _seedPaidUserWithFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('entitlement_remove_ads_lifetime', true);
  await prefs.setBool('entitlement_charts_pro_lifetime', true);
  await prefs.setBool('entitlement_favorites_pro_lifetime', true);
  await prefs.setStringList('favorite_pairs', <String>[
    'USD-BTC',
    'USD-EUR',
    'USD-GBP',
    'USD-CHF',
    'USD-MXN',
    'USD-JPY',
  ]);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const launchSettle = Duration(seconds: 5);
  const chartSettle = Duration(seconds: 8);

  testWidgets('capture all store screenshots', (tester) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
    await _seedPaidUserWithFavorites();

    app.main();
    await tester.pumpAndSettle(launchSettle);
    await binding.takeScreenshot('01-convert');

    await tester.tap(find.byIcon(Icons.show_chart_rounded));
    await tester.pumpAndSettle(launchSettle);

    await tester.tap(find.byKey(const Key('charts_pair_quote')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('BTC'));
    await tester.pumpAndSettle(chartSettle);

    await tester.tap(find.byType(LineChart));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await binding.takeScreenshot('02-chart-btc');

    await tester.tap(
      find.descendant(
        of: find.byType(FloatingPillNav),
        matching: find.byIcon(Icons.star_rounded),
      ),
    );
    await tester.pumpAndSettle(launchSettle);
    await binding.takeScreenshot('03-favorites');
  });
}
