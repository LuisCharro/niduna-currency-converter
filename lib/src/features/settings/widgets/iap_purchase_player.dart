import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_colors.dart';

enum _IapPhase { loading, processing, completed, failed }

class IapPurchasePlayer extends StatefulWidget {
  const IapPurchasePlayer({
    required this.controller,
    required this.product,
    required this.onResult,
    super.key,
  });

  final MonetizationController controller;
  final ProductType product;
  final void Function(bool success) onResult;

  @override
  State<IapPurchasePlayer> createState() => _IapPurchasePlayerState();
}

class _IapPurchasePlayerState extends State<IapPurchasePlayer>
    with SingleTickerProviderStateMixin {
  _IapPhase _phase = _IapPhase.loading;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _runPurchaseFlow();
  }

  Future<void> _runPurchaseFlow() async {
    setState(() => _phase = _IapPhase.loading);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _phase = _IapPhase.processing);

    final success = await _callPurchase();

    if (!mounted) return;

    setState(() => _phase = success ? _IapPhase.completed : _IapPhase.failed);

    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      await _fadeController.reverse();
      if (mounted) widget.onResult(success);
    }
  }

  Future<bool> _callPurchase() async {
    switch (widget.product) {
      case ProductType.removeAds:
        return widget.controller.purchaseRemoveAds();
      case ProductType.chartsPro:
        return widget.controller.purchaseChartsPro();
      case ProductType.subscription:
        return false;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black.withValues(alpha: .92),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildIcon(),
                const SizedBox(height: 20),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: .6),
                  ),
                ),
                if (_phase == _IapPhase.loading) ...[
                  const SizedBox(height: 24),
                  const _ProgressBar(duration: Duration(milliseconds: 800)),
                ],
                if (_phase == _IapPhase.processing) ...[
                  const SizedBox(height: 24),
                  const _ProgressBar(duration: Duration(milliseconds: 1200)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (_phase) {
      case _IapPhase.loading:
        return SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.of(context).primary,
          ),
        );
      case _IapPhase.processing:
        return SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.of(context).primary,
          ),
        );
      case _IapPhase.completed:
        return Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: Colors.green.shade400,
        );
      case _IapPhase.failed:
        return Icon(Icons.error_outline, size: 56, color: Colors.red.shade400);
    }
  }

  String get _title {
    switch (_phase) {
      case _IapPhase.loading:
        return 'Purchasing...';
      case _IapPhase.processing:
        return 'Processing payment...';
      case _IapPhase.completed:
        return 'Purchase complete!';
      case _IapPhase.failed:
        return 'Purchase failed';
    }
  }

  String get _subtitle {
    switch (_phase) {
      case _IapPhase.loading:
        return _productName;
      case _IapPhase.processing:
        return 'Please wait';
      case _IapPhase.completed:
        return _successMessage;
      case _IapPhase.failed:
        return 'Try again later';
    }
  }

  String get _productName {
    switch (widget.product) {
      case ProductType.removeAds:
        return 'Removing ads';
      case ProductType.chartsPro:
        return 'Unlocking all pairs';
      case ProductType.subscription:
        return 'Starting subscription';
    }
  }

  String get _successMessage {
    switch (widget.product) {
      case ProductType.removeAds:
        return 'All ads removed forever';
      case ProductType.chartsPro:
        return 'All chart pairs unlocked';
      case ProductType.subscription:
        return 'Subscription active';
    }
  }
}

class _ProgressBar extends StatefulWidget {
  const _ProgressBar({required this.duration});

  final Duration duration;

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: Colors.white.withValues(alpha: .15),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.of(context).primary),
            minHeight: 4,
          ),
        );
      },
    );
  }
}
