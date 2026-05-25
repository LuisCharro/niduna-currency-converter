import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../monetization/rewarded_ad_service.dart';
import 'ad_helper.dart';

class AdMobRewardedAdService implements RewardedAdService {
  RewardedAd? _rewardedAd;
  Completer<bool>? _resultCompleter;
  bool _rewardEarned = false;

  @override
  Future<bool> showRewardedAd({required String rewardType}) {
    if (_resultCompleter != null) return Future.value(false);

    _rewardEarned = false;
    _resultCompleter = Completer<bool>();

    unawaited(
      _loadAndShowAd(rewardType).catchError((Object error, StackTrace stack) {
        debugPrint('Rewarded ad error: $error');
        _completeResult(false);
      }),
    );

    return _resultCompleter!.future;
  }

  Future<void> _loadAndShowAd(String rewardType) async {
    try {
      _rewardedAd?.dispose();
      _rewardedAd = null;

      await RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: const AdRequest(nonPersonalizedAds: true),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('Rewarded ad loaded for: $rewardType');
            _rewardedAd = ad;
            _setUpFullScreenCallbacks(ad);
            unawaited(_showAd(ad));
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Rewarded ad failed to load: $error');
            _completeResult(false);
          },
        ),
      );
    } catch (error) {
      debugPrint('Rewarded ad failed before loading: $error');
      _completeResult(false);
    }
  }

  void _setUpFullScreenCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad showed full screen');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _completeResult(_rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _completeResult(false);
      },
      onAdImpression: (ad) {
        debugPrint('Rewarded ad impression recorded');
      },
    );
  }

  Future<void> _showAd(RewardedAd ad) async {
    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          _rewardEarned = true;
        },
      );
    } catch (error) {
      debugPrint('Rewarded ad show threw: $error');
      ad.dispose();
      _rewardedAd = null;
      _completeResult(false);
    }
  }

  void _completeResult(bool success) {
    final completer = _resultCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(success);
    }
    _resultCompleter = null;
    _rewardEarned = false;
  }
}
