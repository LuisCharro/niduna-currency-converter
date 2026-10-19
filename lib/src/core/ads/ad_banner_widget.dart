import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_banner_placeholder.dart';
import 'ad_banner_platform.dart';
import 'ad_helper.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({
    this.reserveMinHeight = true,
    this.fixedSize,
    this.platform,
    super.key,
  });

  /// Collapse until content exists when false (for example in a picker).
  final bool reserveMinHeight;

  /// When provided, skip adaptive sizing and reserve this exact slot height.
  final AdSize? fixedSize;
  final AdBannerPlatform? platform;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  static final Map<int, double> _slotHeightByWidth = {};
  late final AdBannerPlatform _platform = widget.platform ?? AdBannerPlatform();
  BannerAd? _ad;
  bool _visible = true;
  bool _loaded = false;
  bool _error = false;
  bool _waitingConsent = false;
  int _generation = 0;
  int? _loadedWidth;
  int? _lastWidth;

  @override
  void initState() {
    super.initState();
    _platform.consent.addListener(_onConsentChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = ModalRoute.isCurrentOf(context) ?? true;
    if (visible != _visible) {
      _visible = visible;
      _invalidate();
    }
  }

  @override
  void didUpdateWidget(covariant AdBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fixedSize != widget.fixedSize) _invalidate();
  }

  void _invalidate() {
    _generation++;
    _loadedWidth = null;
    _waitingConsent = false;
    _loaded = false;
    _error = false;
    final ad = _ad;
    _ad = null;
    if (ad != null) unawaited(ad.dispose());
  }

  void _onConsentChanged() {
    if (!mounted) return;
    if (!_platform.consent.canRequestAds) {
      setState(_invalidate);
    } else if (_visible && _lastWidth != null) {
      if (_waitingConsent) {
        _loadedWidth = null;
        _waitingConsent = false;
      }
      _queueLoad(_lastWidth!);
    }
  }

  bool _valid(int generation) =>
      mounted && _visible && generation == _generation;

  void _queueLoad(int width) {
    if (!_visible || _loadedWidth == width) return;
    _loadedWidth = width;
    final generation = ++_generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_valid(generation)) unawaited(_load(width, generation));
    });
  }

  Future<void> _load(int width, int generation) async {
    final previous = _ad;
    _ad = null;
    if (previous != null) unawaited(previous.dispose());
    setState(() {
      _loaded = false;
      _error = false;
    });
    try {
      await _platform.consent.initialize();
      if (!_valid(generation)) return;
      if (!_platform.consent.canRequestAds) {
        _waitingConsent = true;
        return;
      }
      final size = widget.fixedSize ?? await _platform.adaptiveSize(width);
      if (!_valid(generation)) return;
      if (size == null) {
        setState(() => _error = true);
        return;
      }
      if (widget.fixedSize == null) {
        _slotHeightByWidth[width] = size.height.toDouble().clamp(50, 120);
      }
      final ad = _platform.createAd(
        size,
        BannerAdListener(
          onAdLoaded: (ad) {
            if (!_valid(generation) || !identical(_ad, ad)) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, _) {
            if (!_valid(generation) || !identical(_ad, ad)) return;
            unawaited(ad.dispose());
            setState(() {
              _ad = null;
              _loaded = false;
              _error = true;
            });
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (_) {
      if (!_valid(generation)) return;
      final ad = _ad;
      _ad = null;
      if (ad != null) unawaited(ad.dispose());
      setState(() {
        _loaded = false;
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _platform.consent.removeListener(_onConsentChanged);
    _invalidate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor();
        if (width > 0) {
          _lastWidth = width;
          if (widget.fixedSize == null || width >= widget.fixedSize!.width) {
            _queueLoad(width);
          }
        }
        final ad = _ad;
        final height =
            widget.fixedSize?.height.toDouble() ??
            (ad?.size.height.toDouble() ??
                    _slotHeightByWidth[width] ??
                    _estimatedHeight(width))
                .clamp(50, 120)
                .toDouble();
        final hasContent =
            (_loaded && ad != null) ||
            (_error && AdHelper.showPlaceholderOnFailure);
        return SizedBox(
          height: widget.reserveMinHeight || hasContent ? height : 0,
          child: Center(
            child: _loaded && ad != null
                ? SizedBox(
                    width: ad.size.width.toDouble(),
                    height: ad.size.height.toDouble(),
                    child: _platform.renderAd(ad),
                  )
                : _error && AdHelper.showPlaceholderOnFailure
                ? AdBannerPlaceholder(maxWidth: width.toDouble())
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  double _estimatedHeight(int width) => switch (width) {
    >= 700 => 110,
    >= 520 => 100,
    >= 420 => 90,
    >= 360 => 82,
    _ => 72,
  };
}
