import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/core/ads/admob_rewarded_ad_service.dart';
import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/rewarded_ad_cancellation.dart';

class _LoadError extends Fake implements LoadAdError {}

class _Ad extends Fake implements RewardedAd {
  FullScreenContentCallback<RewardedAd>? callbacks;
  OnUserEarnedRewardCallback? reward;
  int shows = 0;
  int disposals = 0;

  @override
  set fullScreenContentCallback(FullScreenContentCallback<RewardedAd>? value) =>
      callbacks = value;
  @override
  Future<void> show({
    required OnUserEarnedRewardCallback onUserEarnedReward,
  }) async {
    shows++;
    reward = onUserEarnedReward;
    callbacks?.onAdShowedFullScreenContent?.call(this);
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }

  void earn() => reward!(this, RewardItem(1, 'unlock'));
  void dismiss() => callbacks!.onAdDismissedFullScreenContent!(this);
}

void main() {
  late List<RewardedAdLoadCallback> loads;
  late AdMobRewardedAdService service;
  setUp(() {
    loads = [];
    service = AdMobRewardedAdService(
      canRequestAds: () async => true,
      loadAd: (callback) async {
        loads.add(callback);
      },
    );
  });
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'cancel A releases guard; late A success cannot show or finish B',
    () async {
      final token = RewardedAdCancellation();
      final a = service.showRewardedAd(rewardType: 'a', cancellation: token);
      await settle();
      token.cancel();
      expect(await a, false);
      final b = service.showRewardedAd(rewardType: 'b');
      await settle();
      var bFinished = false;
      b.then((_) => bFinished = true);
      final stale = _Ad();
      loads[0].onAdLoaded(stale);
      loads[0].onAdFailedToLoad(_LoadError());
      await settle();
      expect(stale.shows, 0);
      expect(stale.disposals, 1);
      expect(bFinished, false);
      final current = _Ad();
      loads[1].onAdLoaded(current);
      current.earn();
      current.dismiss();
      expect(await b, true);
    },
  );

  test('dismissal without SDK reward returns false', () async {
    final result = service.showRewardedAd(rewardType: 'chart');
    await settle();
    final ad = _Ad();
    loads.single.onAdLoaded(ad);
    ad.dismiss();
    expect(await result, false);
  });

  test(
    'cancel after show keeps SDK operation and persists earned pair entitlement',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = MonetizationController(prefs, adService: service);
      final token = RewardedAdCancellation();
      final result = controller.requestRewardedChartUnlock(
        'CHF',
        'JPY',
        cancellation: token,
      );
      await settle();
      final ad = _Ad();
      loads.single.onAdLoaded(ad);
      token.cancel();
      expect(await service.showRewardedAd(rewardType: 'duplicate'), false);
      ad.earn();
      ad.dismiss();
      expect(await result, true);
      expect(controller.isChartPairUnlocked('JPY', 'CHF'), true);
      expect(prefs.getString('temp_unlocks_registry'), contains('CHF_JPY'));
      controller.dispose();
    },
  );

  test('cancel during consent prevents a late load', () async {
    final consent = Completer<bool>();
    service = AdMobRewardedAdService(
      canRequestAds: () => consent.future,
      loadAd: (callback) async {
        loads.add(callback);
      },
    );
    final token = RewardedAdCancellation();
    final result = service.showRewardedAd(
      rewardType: 'chart',
      cancellation: token,
    );
    token.cancel();
    expect(await result, false);
    consent.complete(true);
    await settle();
    expect(loads, isEmpty);
  });
}
