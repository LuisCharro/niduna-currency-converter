import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_theme.dart';

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
                  style: TextStyle(
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
                if (_phase == _AdPhase.playing) ...[
                  const SizedBox(height: 24),
                  _ProgressBar(),
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
      case _AdPhase.loading:
        return SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppTheme.primary,
          ),
        );
      case _AdPhase.playing:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: .3)),
          ),
          child: Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
        );
      case _AdPhase.completed:
        return Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: Colors.green.shade400,
        );
      case _AdPhase.failed:
        return Icon(Icons.error_outline, size: 56, color: Colors.red.shade400);
    }
  }

  String get _title {
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

  String get _subtitle {
    switch (_phase) {
      case _AdPhase.loading:
        return 'Preparing your reward';
      case _AdPhase.playing:
        return 'Please wait until the ad finishes';
      case _AdPhase.completed:
        return '${widget.base}/${widget.quote} unlocked for 24h';
      case _AdPhase.failed:
        return 'Try again later or unlock forever';
    }
  }
}

class _ProgressBar extends StatefulWidget {
  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();
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
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 4,
          ),
        );
      },
    );
  }
}
