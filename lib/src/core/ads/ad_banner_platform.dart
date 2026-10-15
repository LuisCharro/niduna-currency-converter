import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent_manager.dart';
import 'ad_helper.dart';

/// SDK boundary shared by adaptive and fixed banners.
class AdBannerPlatform {
  AdBannerPlatform({AdConsentManager? consent})
    : consent = consent ?? AdConsentManager.instance;

  final AdConsentManager consent;

  Future<AdSize?> adaptiveSize(int width) =>
      AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

  BannerAd createAd(AdSize size, BannerAdListener listener) => BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    size: size,
    request: const AdRequest(nonPersonalizedAds: true),
    listener: listener,
  );

  Widget renderAd(BannerAd ad) => AdWidget(ad: ad);
}
