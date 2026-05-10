import 'dart:async';

import 'rewarded_ad_service.dart';

class RewardedAdServiceStub implements RewardedAdService {
  @override
  Future<bool> showRewardedAd({required String rewardType}) async {
    // In production, this is where AdMob RewardedAd.load/show happens.
    // Stub simulates the flow with fast-forwarded timing.

    // Simulate "Loading ad..." state would be handled by UI overlay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Simulate "Playing ad... ~15s" (fast-forwarded to ~3s in dev)
    await Future<void>.delayed(const Duration(seconds: 3));

    // Simulate "Ad complete! ✓ Reward granted"
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return true;
  }
}
