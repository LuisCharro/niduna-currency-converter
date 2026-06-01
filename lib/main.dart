import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';

import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Tell home_widget which iOS App Group to use. Required on iOS for the
  // widget extension to read data the main app pushes via
  // HomeWidget.saveWidgetData. Android reads SharedPreferences directly
  // via the plugin and ignores this. The App Group is declared in
  // ios/Runner/Runner.entitlements and ios/Runner/Widgets/NidunaWidget/
  // NidunaWidget.entitlements. No-op on Android / when the group
  // isn't granted.
  unawaited(
    HomeWidget.setAppGroupId(
      // iOS only — Android receives this argument and ignores it.
      // Wrap in try because on test/non-widget environments the
      // method channel may be missing.
      'group.com.niduna.currencyConverter',
    ).catchError((Object e, StackTrace st) {
      debugPrint('HomeWidget.setAppGroupId failed: $e');
      return false;
    }),
  );
  unawaited(MobileAds.instance.initialize());
  runApp(const CurrencyConverterApp());
}
