import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';

import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _trustDevProxyCa();
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
      // ignore: avoid_print
      print('HomeWidget.setAppGroupId failed: $e');
      return false;
    }),
  );
  unawaited(MobileAds.instance.initialize());
  runApp(const CurrencyConverterApp());
}

/// Debug-only: trust an additional CA so HTTPS works behind corporate
/// TLS-inspecting proxies (e.g. Zscaler) on dev machines. Dart's HTTP
/// client ignores Android's user-installed CAs, so the proxy's root CA
/// must be added to the Dart trust store explicitly. The PEM is read
/// from the device and is never bundled with the app; when the file is
/// absent (normal networks, CI, release builds) this is a no-op.
void _trustDevProxyCa() {
  if (!kDebugMode) return;
  if (kIsWeb || !Platform.isAndroid) return;
  // Locations the app can read without extra permissions. Place the
  // proxy CA there from the dev machine, e.g. for the internal dir:
  //   adb push proxy_ca.pem /data/local/tmp/dev_trusted_ca.pem
  //   adb shell run-as <applicationId> sh -c \
  //     'mkdir -p files && cp /data/local/tmp/dev_trusted_ca.pem files/'
  const pemPaths = [
    '/data/data/com.niduna.currency_converter/files/dev_trusted_ca.pem',
    '/sdcard/Android/data/com.niduna.currency_converter/files/'
        'dev_trusted_ca.pem',
    // Survives app reinstalls (integration test runs wipe app data).
    '/data/local/tmp/dev_trusted_ca.pem',
  ];
  for (final path in pemPaths) {
    try {
      final pem = File(path).readAsBytesSync();
      SecurityContext.defaultContext.setTrustedCertificatesBytes(pem);
      debugPrint('Dev proxy CA trusted from $path');
      return;
    } on Exception {
      // File missing or unreadable: try the next location.
    }
  }
}
