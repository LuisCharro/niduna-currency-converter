import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_progress_bar.dart';
import '../../../../l10n/app_localizations.dart';

enum _AdPhase { loading, playing, completed, failed }

class RewardedAdPlayer extends StatefulWidget {
  const RewardedAdPlayer({
    required this.controller,
    required this.base,
    required this.quote,
    required this.onResult,
    super.key,
  });

  final MonetizationController controller;
  final String base;
  final String quote;
  final void Function(bool granted) onResult;

  @override
  State<RewardedAdPlayer> createState() => _RewardedAdPlayerState();
}

class _RewardedAdPlayerState extends State<RewardedAdPlayer>
    with SingleTickerProviderStateMixin {
  static const Color _overlayInk = Color(0xFF171D14);
  static const Color _overlayPaper = Color(0xFFF6F8EF);

  _AdPhase _phase = _AdPhase.loading;
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
    setState(() => _phase = _AdPhase.loading);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _phase = _AdPhase.playing);

    final success = await widget.controller.requestRewardedChartUnlock(
      widget.base,
      widget.quote,
    );

    if (!mounted) return;

    setState(() => _phase = success ? _AdPhase.completed : _AdPhase.failed);

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
                if (_phase == _AdPhase.playing) ...[
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
      case _AdPhase.loading:
        return SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.of(context).trendUp,
          ),
        );
      case _AdPhase.playing:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _overlayPaper.withValues(alpha: .28)),
          ),
          child: Icon(
            Icons.play_circle_fill,
            size: 40,
            color: _overlayPaper.withValues(alpha: .92),
          ),
        );
      case _AdPhase.completed:
        return Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: AppColors.of(context).trendUp,
        );
      case _AdPhase.failed:
        return Icon(Icons.error_outline, size: 56, color: AppColors.of(context).trendDown);
    }
  }

  String _title(AppLocalizations? l10n) {
    switch (_phase) {
      case _AdPhase.loading:
        return 'Loading ad...';
      case _AdPhase.playing:
        return 'Watching ad';
      case _AdPhase.completed:
        return 'Reward granted!';
      case _AdPhase.failed:
        return 'Ad unavailable';
    }
  }

  String _subtitle(AppLocalizations? l10n) {
    switch (_phase) {
      case _AdPhase.loading:
        return 'Preparing your reward';
      case _AdPhase.playing:
        return 'Please wait until the ad finishes';
      case _AdPhase.completed:
        return '${widget.base}/${widget.quote} unlocked for 24h';
      case _AdPhase.failed:
        return l10n?.tryAgainLater ?? 'Try again later or unlock forever';
    }
  }
}
