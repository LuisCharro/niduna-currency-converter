import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/monetization/monetization_controller.dart';
import '../../../core/monetization/rewarded_ad_service.dart';
import '../../../core/theme/app_colors.dart';

enum _AdPhase { loading, completed, failed }

/// Waiting UI only; the native SDK owns the actual ad and reward timing.
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

class _RewardedAdPlayerState extends State<RewardedAdPlayer> {
  final _cancellation = RewardedAdCancellation();
  _AdPhase _phase = _AdPhase.loading;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    bool granted;
    try {
      granted = await widget.controller.requestRewardedChartUnlock(
        widget.base,
        widget.quote,
        cancellation: _cancellation,
      );
    } catch (_) {
      granted = false;
    }
    if (!mounted || _cancellation.isCancelled) return;
    setState(() => _phase = granted ? _AdPhase.completed : _AdPhase.failed);
    if (granted) widget.onResult(true);
  }

  @override
  void dispose() {
    _cancellation.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          _phase == _AdPhase.failed
              ? loc.chartAdUnavailable
              : loc.chartAdLoading,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_phase == _AdPhase.loading)
                const CircularProgressIndicator()
              else
                Icon(
                  _phase == _AdPhase.completed
                      ? Icons.check_circle_outline
                      : Icons.info_outline_rounded,
                  size: 40,
                  color: colors.primary,
                ),
              const SizedBox(height: 16),
              Text(
                _phase == _AdPhase.failed
                    ? loc.tryAgainLater
                    : loc.chartAdInstructions,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => widget.onResult(false),
                child: Text(loc.btnCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
