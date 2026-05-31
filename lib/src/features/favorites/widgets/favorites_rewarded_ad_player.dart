import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_progress_bar.dart';
import '../../../../l10n/app_localizations.dart';

enum _FavoritesAdPhase { loading, playing, completed, failed }

class FavoritesRewardedAdPlayer extends StatefulWidget {
  const FavoritesRewardedAdPlayer({
    required this.controller,
    required this.onResult,
    super.key,
  });

  final MonetizationController controller;
  final void Function(bool granted) onResult;

  @override
  State<FavoritesRewardedAdPlayer> createState() =>
      _FavoritesRewardedAdPlayerState();
}

class _FavoritesRewardedAdPlayerState extends State<FavoritesRewardedAdPlayer>
    with SingleTickerProviderStateMixin {
  static const Color _overlayInk = Color(0xFF171D14);
  static const Color _overlayPaper = Color(0xFFF6F8EF);

  _FavoritesAdPhase _phase = _FavoritesAdPhase.loading;
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
    _runAdFlow();
  }

  Future<void> _runAdFlow() async {
    setState(() => _phase = _FavoritesAdPhase.loading);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _phase = _FavoritesAdPhase.playing);

    final success =
        await widget.controller.requestRewardedFavoritesBoost();

    if (!mounted) return;

    setState(() =>
        _phase = success ? _FavoritesAdPhase.completed : _FavoritesAdPhase.failed);

    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      await _fadeController.reverse();
      if (mounted) widget.onResult(success);
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
        color: _overlayInk.withValues(alpha: .94),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildIcon(context),
                const SizedBox(height: 20),
                Text(
                  _title(l10n),
                  textAlign: TextAlign.center,
                  style: AppTheme.heading.copyWith(color: _overlayPaper),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(l10n),
                  textAlign: TextAlign.center,
                  style: AppTheme.caption.copyWith(
                    color: _overlayPaper.withValues(alpha: .65),
                  ),
                ),
                if (_phase == _FavoritesAdPhase.playing) ...<Widget>[
                  const SizedBox(height: 24),
                  AnimatedProgressBar(
                    duration: const Duration(seconds: 4),
                    accentColor: AppColors.of(context).trendUp,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    switch (_phase) {
      case _FavoritesAdPhase.loading:
        return SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.of(context).trendUp,
          ),
        );
      case _FavoritesAdPhase.playing:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: _overlayPaper.withValues(alpha: .28)),
          ),
          child: Icon(
            Icons.play_circle_fill,
            size: 40,
            color: _overlayPaper.withValues(alpha: .92),
          ),
        );
      case _FavoritesAdPhase.completed:
        return Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: AppColors.of(context).trendUp,
        );
      case _FavoritesAdPhase.failed:
        return Icon(
          Icons.error_outline,
          size: 56,
          color: AppColors.of(context).trendDown,
        );
    }
  }

  String _title(AppLocalizations? l10n) {
    switch (_phase) {
      case _FavoritesAdPhase.loading:
        return 'Loading ad...';
      case _FavoritesAdPhase.playing:
        return 'Watching ad';
      case _FavoritesAdPhase.completed:
        return 'Reward granted!';
      case _FavoritesAdPhase.failed:
        return 'Ad unavailable';
    }
  }

  String _subtitle(AppLocalizations? l10n) {
    switch (_phase) {
      case _FavoritesAdPhase.loading:
        return 'Preparing your reward';
      case _FavoritesAdPhase.playing:
        return 'Please wait until the ad finishes';
      case _FavoritesAdPhase.completed:
        return 'You can now save up to 6 pairs for 24h';
      case _FavoritesAdPhase.failed:
        return l10n?.tryAgainLater ?? 'Try again later or unlock forever';
    }
  }
}
