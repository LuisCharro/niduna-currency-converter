import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_progress_bar.dart';
import '../../../../l10n/app_localizations.dart';
import 'iap_purchase_copy.dart';

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
      case ProductType.favoritesPro:
        return widget.controller.purchaseFavoritesPro();
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
    final l10n = AppLocalizations.of(context);
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
                  _title(l10n),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(l10n),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: .6),
                  ),
                ),
                if (_phase == _IapPhase.loading) ...[
                  const SizedBox(height: 24),
                  AnimatedProgressBar(duration: Duration(milliseconds: 800)),
                ],
                if (_phase == _IapPhase.processing) ...[
                  const SizedBox(height: 24),
                  AnimatedProgressBar(duration: Duration(milliseconds: 1200)),
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

  String _title(AppLocalizations? l10n) {
    switch (_phase) {
      case _IapPhase.loading:
        return l10n?.purchasing ?? "Purchasing...";
      case _IapPhase.processing:
        return l10n?.processingPayment ?? "Processing payment...";
      case _IapPhase.completed:
        return l10n?.purchaseComplete ?? "Purchase complete!";
      case _IapPhase.failed:
        return l10n?.purchaseFailed ?? "Purchase failed";
    }
  }

  String _subtitle(AppLocalizations? l10n) {
    switch (_phase) {
      case _IapPhase.loading:
        return iapProductName(l10n, widget.product);
      case _IapPhase.processing:
        return l10n?.pleaseWait ?? "Please wait";
      case _IapPhase.completed:
        return iapSuccessMessage(l10n, widget.product);
      case _IapPhase.failed:
        return l10n?.tryAgainLater ?? "Try again later";
    }
  }
}
