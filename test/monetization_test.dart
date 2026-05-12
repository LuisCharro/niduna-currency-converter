import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/rewarded_ad_service.dart';

class _ImmediateAdService implements RewardedAdService {
  @override
  Future<bool> showRewardedAd({required String rewardType}) async => true;
}

void main() {
  late SharedPreferences prefs;
  late MonetizationController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    controller = MonetizationController(
      prefs,
      adService: _ImmediateAdService(),
    );
  });

  group('MonetizationController defaults', () {
    test('starts with no entitlements', () {
      expect(controller.hasActiveSubscription, isFalse);
      expect(controller.hasRemoveAdsLifetime, isFalse);
      expect(controller.hasChartsProLifetime, isFalse);
      expect(controller.adsEnabled, isTrue);
      expect(controller.canSelectAnyChartPair, isFalse);
      expect(controller.canUseIntradayRanges, isFalse);
      expect(controller.canOfferRewardedChartUnlock, isTrue);
    });
  });

  group('isChartPairUnlocked', () {
    test('free default pair USD/EUR is unlocked without entitlements', () {
      expect(controller.isChartPairUnlocked('USD', 'EUR'), isTrue);
      expect(controller.isChartPairUnlocked('EUR', 'USD'), isTrue);
    });

    test('non-default pair GBP/JPY is locked without entitlements', () {
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isFalse);
    });

    test('subscription unlocks any pair', () async {
      await controller.setSubscriptionActive(true);
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isTrue);
    });

    test('Charts Pro unlocks any pair', () async {
      await controller.setChartsProLifetime(true);
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isTrue);
    });

    test('Remove Ads alone does not unlock pairs', () async {
      await controller.setRemoveAdsLifetime(true);
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isFalse);
    });

    test('subscription takes priority over Charts Pro', () async {
      await controller.setChartsProLifetime(true);
      await controller.setSubscriptionActive(true);
      await controller.setChartsProLifetime(false);
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isTrue);
    });

    test('subscription expired falls back to free only', () async {
      await controller.setSubscriptionActive(true);
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isTrue);
      await controller.setSubscriptionActive(false);
      expect(controller.isChartPairUnlocked('GBP', 'JPY'), isFalse);
    });
  });

  group('canOfferRewardedChartUnlock', () {
    test('pure-free user can offer rewarded', () {
      expect(controller.canOfferRewardedChartUnlock, isTrue);
    });

    test('subscription user cannot offer rewarded', () async {
      await controller.setSubscriptionActive(true);
      expect(controller.canOfferRewardedChartUnlock, isFalse);
    });

    test('Remove Ads user cannot offer rewarded', () async {
      await controller.setRemoveAdsLifetime(true);
      expect(controller.canOfferRewardedChartUnlock, isFalse);
    });

    test('Charts Pro user cannot offer rewarded', () async {
      await controller.setChartsProLifetime(true);
      expect(controller.canOfferRewardedChartUnlock, isFalse);
    });
  });

  group('adsEnabled', () {
    test('ads enabled by default', () {
      expect(controller.adsEnabled, isTrue);
    });

    test('subscription hides ads', () async {
      await controller.setSubscriptionActive(true);
      expect(controller.adsEnabled, isFalse);
    });

    test('Remove Ads hides ads without subscription', () async {
      await controller.setRemoveAdsLifetime(true);
      expect(controller.adsEnabled, isFalse);
    });

    test('both subscription + Remove Ads hide ads', () async {
      await controller.setSubscriptionActive(true);
      await controller.setRemoveAdsLifetime(true);
      expect(controller.adsEnabled, isFalse);
    });

    test('subscription expired brings back ads (no Remove Ads)', () async {
      await controller.setSubscriptionActive(true);
      expect(controller.adsEnabled, isFalse);
      await controller.setSubscriptionActive(false);
      expect(controller.adsEnabled, isTrue);
    });
  });

  group('canUseIntradayRanges', () {
    test('no intraday access by default', () {
      expect(controller.canUseIntradayRanges, isFalse);
    });

    test('subscription enables intraday', () async {
      await controller.setSubscriptionActive(true);
      expect(controller.canUseIntradayRanges, isTrue);
    });

    test('Charts Pro does not enable intraday', () async {
      await controller.setChartsProLifetime(true);
      expect(controller.canUseIntradayRanges, isFalse);
    });
  });

  group('requestRewardedChartUnlock', () {
    test('pure-free user can request and receive unlock', () async {
      final result = await controller.requestRewardedChartUnlock('USD', 'GBP');
      expect(result, isTrue);
      expect(controller.isChartPairUnlocked('USD', 'GBP'), isTrue);
      expect(controller.isChartPairUnlocked('GBP', 'USD'), isTrue);
    });

    test('Remove Ads user cannot request rewarded', () async {
      await controller.setRemoveAdsLifetime(true);
      final result = await controller.requestRewardedChartUnlock('USD', 'GBP');
      expect(result, isFalse);
      expect(controller.isChartPairUnlocked('USD', 'GBP'), isFalse);
    });

    test('subscription user cannot request rewarded', () async {
      await controller.setSubscriptionActive(true);
      final result = await controller.requestRewardedChartUnlock('USD', 'GBP');
      expect(result, isFalse);
    });
  });
}
