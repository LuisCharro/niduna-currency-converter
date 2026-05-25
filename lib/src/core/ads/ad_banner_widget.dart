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
  static final Map<int, double> _slotHeightByWidth = <int, double>{};

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

      _slotHeightByWidth[width] = size.height.toDouble().clamp(
        _minSlotHeight,
        120,
      );

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
        final reservedHeight = width > 0
            ? (_slotHeightByWidth[width] ?? _estimatedSlotHeight(width))
            : _minSlotHeight;
        final slotHeight = (ad?.size.height.toDouble() ?? reservedHeight)
            .clamp(_minSlotHeight, 120)
            .toDouble();
        final frameHeight = slotHeight > _minSlotHeight
            ? slotHeight
            : _minSlotHeight;
        Widget content = const SizedBox.shrink();

        if (_isLoaded && ad != null) {
          content = SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          );
        } else if (_hasLoadError && AdHelper.showPlaceholderOnFailure) {
          content = AdBannerPlaceholder(maxWidth: width.toDouble());
        }

        return SizedBox(
          height: frameHeight,
          child: Center(child: content),
        );
      },
    );
  }

  double _estimatedSlotHeight(int width) {
    if (width >= 700) return 110;
    if (width >= 520) return 100;
    if (width >= 420) return 90;
    if (width >= 360) return 82;
    return 72;
  }
}
