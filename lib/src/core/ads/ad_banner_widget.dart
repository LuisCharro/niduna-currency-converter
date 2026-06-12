import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_banner_placeholder.dart';
import 'ad_helper.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  static const double _minSlotHeight = 50;

  BannerAd? _bannerAd;
  bool _hasLoadError = false;
  bool _isLoaded = false;
  int? _loadedWidth;
  int? _pendingLoadWidth;

  Future<void> _loadBannerAd(int width) async {
    _bannerAd?.dispose();
    _bannerAd = null;
    _hasLoadError = false;
    _isLoaded = false;

    try {
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
      if (!mounted || size == null) {
        if (mounted) {
          setState(() {
            _hasLoadError = true;
          });
        }
        return;
      }

      final ad = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: size,
        request: const AdRequest(nonPersonalizedAds: true),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            if (!mounted || !identical(loadedAd, _bannerAd)) return;
            setState(() {
              _isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: $error');
            ad.dispose();
            if (mounted && identical(ad, _bannerAd)) {
              setState(() {
                _bannerAd = null;
                _hasLoadError = true;
                _isLoaded = false;
              });
            }
          },
        ),
      );

      _bannerAd = ad;
      await ad.load();
    } catch (error) {
      debugPrint('Banner ad skipped: $error');
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) {
        setState(() {
          _hasLoadError = true;
          _isLoaded = false;
        });
      }
    }
  }

  void _queueLoad(int width) {
    if (_pendingLoadWidth == width || _loadedWidth == width) return;
    _pendingLoadWidth = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingLoadWidth == null) return;
      final nextWidth = _pendingLoadWidth!;
      _pendingLoadWidth = null;
      if (_loadedWidth == nextWidth) return;
      _loadedWidth = nextWidth;
      unawaited(_loadBannerAd(nextWidth));
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor();
        if (width > 0) _queueLoad(width);

        final ad = _bannerAd;
        Widget content = const SizedBox.shrink();
        // Reserve the full slot only once an ad is actually showing.
        // While loading keep a minimal strip, and collapse entirely on
        // failure (unless the debug placeholder is enabled) so screens
        // don't show a large empty void when no ad fills.
        double frameHeight = _minSlotHeight;

        if (_isLoaded && ad != null) {
          frameHeight = ad.size.height
              .toDouble()
              .clamp(_minSlotHeight, 120)
              .toDouble();
          content = SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          );
        } else if (_hasLoadError) {
          if (AdHelper.showPlaceholderOnFailure) {
            content = AdBannerPlaceholder(maxWidth: width.toDouble());
          } else {
            frameHeight = 0;
          }
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: SizedBox(
            height: frameHeight,
            child: Center(child: content),
          ),
        );
      },
    );
  }
}
