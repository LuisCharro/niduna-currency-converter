import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/purchase_service.dart';
import 'package:currency_converter/src/core/monetization/purchase_service_stub.dart';

class _ImmediatePurchaseService implements PurchaseService {
  @override
  Future<bool> purchase(ProductType product) async => true;
}

class _FailingPurchaseService implements PurchaseService {
  @override
  Future<bool> purchase(ProductType product) async => false;
}

void main() {
  late SharedPreferences prefs;
  late MonetizationController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    controller = MonetizationController(
      prefs,
      purchaseService: _ImmediatePurchaseService(),
    );
  });

  group('PurchaseServiceStub', () {
    test('purchase returns true for removeAds', () async {
      final stub = PurchaseServiceStub();
      expect(await stub.purchase(ProductType.removeAds), isTrue);
    });

    test('purchase returns true for chartsPro', () async {
      final stub = PurchaseServiceStub();
      expect(await stub.purchase(ProductType.chartsPro), isTrue);
    });

    test('purchase takes approximately 2s', () async {
      final stub = PurchaseServiceStub();
      final stopwatch = Stopwatch()..start();
      await stub.purchase(ProductType.removeAds);
      stopwatch.stop();
      expect(stopwatch.elapsed.inMilliseconds, greaterThanOrEqualTo(1900));
      expect(stopwatch.elapsed.inMilliseconds, lessThan(3000));
    });
  });

  group('MonetizationController.purchaseRemoveAds', () {
    test('sets Remove Ads entitlement on success', () async {
      final result = await controller.purchaseRemoveAds();
      expect(result, isTrue);
      expect(controller.hasRemoveAdsLifetime, isTrue);
    });

    test('hides ads after Remove Ads purchase', () async {
      expect(controller.adsEnabled, isTrue);
      await controller.purchaseRemoveAds();
      expect(controller.adsEnabled, isFalse);
    });

    test('returns false on failure', () async {
      final failing = MonetizationController(
        prefs,
        purchaseService: _FailingPurchaseService(),
      );
      final result = await failing.purchaseRemoveAds();
      expect(result, isFalse);
      expect(controller.hasRemoveAdsLifetime, isFalse);
    });
  });

  group('MonetizationController.purchaseChartsPro', () {
    test('sets Charts Pro entitlement on success', () async {
      final result = await controller.purchaseChartsPro();
      expect(result, isTrue);
      expect(controller.hasChartsProLifetime, isTrue);
    });

    test('unlocks any chart pair after Charts Pro purchase', () async {
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isFalse);
      await controller.purchaseChartsPro();
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isTrue);
    });

    test('does NOT hide ads after Charts Pro purchase', () async {
      await controller.purchaseChartsPro();
      expect(controller.adsEnabled, isTrue);
    });

    test('returns false on failure', () async {
      final failing = MonetizationController(
        prefs,
        purchaseService: _FailingPurchaseService(),
      );
      final result = await failing.purchaseChartsPro();
      expect(result, isFalse);
      expect(controller.hasChartsProLifetime, isFalse);
    });
  });

  group('ProductType enum', () {
    test('has removeAds value', () {
      expect(ProductType.removeAds, isNotNull);
    });

    test('has chartsPro value', () {
      expect(ProductType.chartsPro, isNotNull);
    });

    test('has subscription value', () {
      expect(ProductType.subscription, isNotNull);
    });
  });
}
