import 'dart:io' show Platform;

class AdHelper {
  AdHelper._();

  static const bool _useTestAds = bool.fromEnvironment(
    'ADMOB_USE_TEST_ADS',
    defaultValue: true,
  );

  static bool get showPlaceholderOnFailure => _useTestAds;

  static const String _androidBannerAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_AD_UNIT_ID',
  );

  static const String _iosBannerAdUnitId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_AD_UNIT_ID',
  );

  static const String _androidRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_AD_UNIT_ID',
  );

  static const String _iosRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_AD_UNIT_ID',
  );

  static String get bannerAdUnitId {
    if (_useTestAds) return _testBannerAdUnitId;
    final id = Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
    if (id.isEmpty) throw StateError('Missing AdMob banner ad unit ID');
    return id;
  }

  static String get rewardedAdUnitId {
    if (_useTestAds) return _testRewardedAdUnitId;
    final id = Platform.isAndroid
        ? _androidRewardedAdUnitId
        : _iosRewardedAdUnitId;
    if (id.isEmpty) throw StateError('Missing AdMob rewarded ad unit ID');
    return id;
  }

  static String get _testBannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9214589741'
      : 'ca-app-pub-3940256099942544/2435281174';

  static String get _testRewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
}
