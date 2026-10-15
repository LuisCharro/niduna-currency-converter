import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../monetization/rewarded_ad_service.dart';
import 'ad_consent_manager.dart';
import 'ad_helper.dart';

/// Owns one SDK operation at a time, independently of the presenting route.
class AdMobRewardedAdService implements RewardedAdService {
  AdMobRewardedAdService({
    Future<bool> Function()? canRequestAds,
    Future<void> Function(RewardedAdLoadCallback)? loadAd,
  }) : _canRequestAds = canRequestAds ?? _requestConsent,
       _loadAd = loadAd ?? _loadSdkAd;

  final Future<bool> Function() _canRequestAds;
  final Future<void> Function(RewardedAdLoadCallback) _loadAd;
  _RewardedOperation? _active;

  static Future<bool> _requestConsent() async {
    await AdConsentManager.instance.initialize();
    return AdConsentManager.instance.canRequestAds;
  }

  static Future<void> _loadSdkAd(RewardedAdLoadCallback callback) =>
      RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: const AdRequest(nonPersonalizedAds: true),
        rewardedAdLoadCallback: callback,
      );

  @override
  Future<bool> showRewardedAd({
    required String rewardType,
    RewardedAdCancellation? cancellation,
  }) {
    if (_active != null || cancellation?.isCancelled == true) {
      return Future.value(false);
    }
    final operation = _RewardedOperation(cancellation);
    _active = operation;
    operation.onCancel = () {
      // Native fullscreen presentation belongs to the SDK until dismissal.
      if (!operation.shown) _finish(operation, false);
    };
    cancellation?.addListener(operation.onCancel);
    unawaited(_load(operation));
    return operation.result.future;
  }

  bool _isActive(_RewardedOperation operation) => identical(_active, operation);

  Future<void> _load(_RewardedOperation operation) async {
    try {
      final permitted = await _canRequestAds();
      if (!_isActive(operation)) return;
      if (!permitted) {
        _finish(operation, false);
        return;
      }
      await _loadAd(
        RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (!_isActive(operation)) {
              unawaited(ad.dispose());
              return;
            }
            operation.ad = ad;
            ad.fullScreenContentCallback =
                FullScreenContentCallback<RewardedAd>(
                  onAdDismissedFullScreenContent: (_) =>
                      _finish(operation, operation.earned),
                  onAdFailedToShowFullScreenContent: (_, _) =>
                      _finish(operation, false),
                );
            operation.shown = true;
            unawaited(_show(operation, ad));
          },
          onAdFailedToLoad: (_) => _finish(operation, false),
        ),
      );
    } catch (_) {
      _finish(operation, false);
    }
  }

  Future<void> _show(_RewardedOperation operation, RewardedAd ad) async {
    try {
      await ad.show(
        onUserEarnedReward: (_, _) {
          if (_isActive(operation)) operation.earned = true;
        },
      );
    } catch (_) {
      _finish(operation, false);
    }
  }

  void _finish(_RewardedOperation operation, bool success) {
    // A callback from an abandoned load may never complete a newer operation.
    if (!_isActive(operation)) return;
    _active = null;
    operation.cancellation?.removeListener(operation.onCancel);
    final ad = operation.ad;
    operation.ad = null;
    if (ad != null) unawaited(ad.dispose());
    operation.result.complete(success);
  }
}

class _RewardedOperation {
  _RewardedOperation(this.cancellation);

  final RewardedAdCancellation? cancellation;
  final Completer<bool> result = Completer<bool>();
  late final void Function() onCancel;
  RewardedAd? ad;
  bool shown = false;
  bool earned = false;
}
