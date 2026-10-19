import 'rewarded_ad_cancellation.dart';

export 'rewarded_ad_cancellation.dart';

abstract class RewardedAdService {
  Future<bool> showRewardedAd({
    required String rewardType,
    RewardedAdCancellation? cancellation,
  });
}
