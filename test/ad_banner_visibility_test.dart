import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:currency_converter/src/core/ads/ad_banner_widget.dart';
import 'package:currency_converter/src/core/ads/ad_banner_platform.dart';
import 'package:currency_converter/src/core/ads/ad_consent_manager.dart';

class _Banner extends Fake implements BannerAd {
  _Banner(this.size, this.listener);
  @override
  final AdSize size;
  @override
  final BannerAdListener listener;
  int loads = 0;
  int disposals = 0;
  @override
  Future<void> load() async {
    loads++;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

class _Platform extends AdBannerPlatform {
  _Platform({Completer<bool>? consent})
    : super(
        consent: AdConsentManager.forTesting(
          () => consent?.future ?? Future.value(true),
        ),
      );
  final ads = <_Banner>[];
  final sizes = <Completer<AdSize?>>[];
  int sizingCalls = 0;
  @override
  Future<AdSize?> adaptiveSize(int width) {
    sizingCalls++;
    return sizes.isEmpty
        ? Future.value(AdSize.banner)
        : sizes.removeAt(0).future;
  }

  @override
  BannerAd createAd(AdSize size, BannerAdListener listener) {
    final ad = _Banner(size, listener);
    ads.add(ad);
    return ad;
  }

  @override
  Widget renderAd(BannerAd ad) => const SizedBox(key: Key('rendered_ad'));
}

void main() {
  testWidgets('denied consent settles without retrying every frame', (
    tester,
  ) async {
    final consent = Completer<bool>()..complete(false);
    final platform = _Platform(consent: consent);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdBannerWidget(platform: platform)),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 1),
    );
    expect(platform.ads, isEmpty);
  });
  testWidgets(
    'fixed 320x50 banner skips adaptive sizing and hides under child route',
    (tester) async {
      final platform = _Platform();
      final nav = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: nav,
          home: Scaffold(
            body: AdBannerWidget(fixedSize: AdSize.banner, platform: platform),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(platform.sizingCalls, 0);
      expect(platform.ads, hasLength(1));
      final a = platform.ads.single;
      a.listener.onAdLoaded!(a);
      await tester.pump();
      expect(tester.getSize(find.byType(AdBannerWidget)).height, 50);
      nav.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('child')),
        ),
      );
      await tester.pumpAndSettle();
      expect(a.disposals, 1);
      expect(
        find.byKey(const Key('rendered_ad'), skipOffstage: false),
        findsNothing,
      );
      a.listener.onAdLoaded!(a);
      await tester.pumpAndSettle();
      expect(platform.ads, hasLength(1));
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      expect(platform.ads, hasLength(2));
    },
  );

  testWidgets(
    'covered route invalidates deferred sizing; stale result cannot replace new banner',
    (tester) async {
      final platform = _Platform();
      final delayedSize = Completer<AdSize?>();
      platform.sizes.add(delayedSize);
      final nav = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: nav,
          home: Scaffold(body: AdBannerWidget(platform: platform)),
        ),
      );
      await tester.pumpAndSettle();
      nav.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      );
      await tester.pumpAndSettle();
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      expect(platform.ads, hasLength(1));
      delayedSize.complete(AdSize.leaderboard);
      await tester.pumpAndSettle();
      expect(platform.ads, hasLength(1));
      expect(platform.ads.single.size, AdSize.banner);
    },
  );

  testWidgets('consent resolving while covered starts no hidden ad load', (
    tester,
  ) async {
    final consent = Completer<bool>();
    final platform = _Platform(consent: consent);
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: Scaffold(body: AdBannerWidget(platform: platform)),
      ),
    );
    await tester.pumpAndSettle();
    nav.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pumpAndSettle();
    consent.complete(true);
    await tester.pumpAndSettle();
    expect(platform.ads, isEmpty);
    nav.currentState!.pop();
    await tester.pumpAndSettle();
    expect(platform.ads, hasLength(1));
  });
}
