import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/purchase_service.dart';
import '../../core/theme/app_theme.dart';
import '../convert/widgets/ad_banner_placeholder.dart';
import '../settings/widgets/iap_purchase_player.dart';
import 'presentation/charts_controller.dart';
import 'widgets/chart_header.dart';
import 'widgets/chart_summary.dart';
import 'widgets/pair_selector.dart';
import 'widgets/range_selector.dart';
import 'widgets/rate_chart.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({
    required this.controller,
    required this.monetization,
    super.key,
  });

  final ChartsController controller;
  final MonetizationController monetization;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _swapVersion = 0;
  String _lastPairKey = '';

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  void _handleSwap() {
    setState(() {
      _swapVersion++;
      _lastPairKey =
          '${widget.controller.state.quote}-${widget.controller.state.base}';
    });
    widget.controller.swapPair();
  }

  void _showRemoveAds(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => IapPurchasePlayer(
          controller: widget.monetization,
          product: ProductType.removeAds,
          onResult: (success) => Navigator.of(context).pop(success),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bg,
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final state = widget.controller.state;
            return ListenableBuilder(
              listenable: widget.monetization,
              builder: (context, _) {
                return Column(
                  children: <Widget>[
                    ChartHeader(
                      base: state.base,
                      quote: state.quote,
                      rate: state.currentRate,
                      changePercent: state.changePercent,
                      onSwap: _handleSwap,
                      lastUpdated: state.lastUpdated,
                    ),
                    Expanded(child: _buildChartArea(state)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                      child: RangeSelector(
                        selected: state.range,
                        onChanged: widget.controller.setRange,
                        canUseLockedRanges:
                            widget.monetization.canUseIntradayRanges,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                      child: PairSelector(
                        base: state.base,
                        quote: state.quote,
                        onPairChanged: widget.controller.setPair,
                        onSwap: _handleSwap,
                        controller: widget.monetization,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
                      child: ChartSummary(
                        high: state.high,
                        low: state.low,
                        changePercent: state.changePercent,
                      ),
                    ),
                    if (state.lastUpdated != null)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.monetization.adsEnabled ? 10 : 96,
                        ),
                        child: Text(
                          'Tap currencies above to explore other pairs',
                          textAlign: TextAlign.center,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.subtle,
                          ),
                        ),
                      ),
                    if (widget.monetization.adsEnabled) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 112),
                        child: Column(
                          children: [
                            const AdBannerPlaceholder(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showRemoveAds(context),
                                  icon: Icon(
                                    Icons.ad_units_outlined,
                                    size: 16,
                                    color: AppTheme.trendDown,
                                  ),
                                  label: Text(
                                    'Remove ads',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.trendDown,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: AppTheme.trendDown.withValues(
                                        alpha: .4,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.pillRadius,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    backgroundColor: AppTheme.trendDown
                                        .withValues(alpha: .06),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartArea(ChartState state) {
    if (state.status == ChartStatus.loading && state.data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ChartStatus.error && state.data.isEmpty) {
      return _ErrorState(
        message: state.message,
        onRetry: widget.controller.load,
      );
    }

    if (state.data.isEmpty) {
      return _EmptyChart();
    }

    final currentPairKey =
        '${widget.controller.state.base}-${widget.controller.state.quote}';
    final isSwap =
        _lastPairKey.isNotEmpty &&
        _lastPairKey != currentPairKey &&
        _swapVersion > 0;

    if (isSwap) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _lastPairKey = currentPairKey);
      });
    }

    return AnimatedSwitcher(
      duration: isSwap
          ? const Duration(milliseconds: 650)
          : const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        if (isSwap) {
          final flip = Tween<double>(begin: 0, end: 1).animate(animation);
          return RotationTransition(
            turns: flip,
            child: FadeTransition(opacity: animation, child: child),
          );
        }
        final slide = Tween<Offset>(
          begin: const Offset(.03, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Padding(
        key: ValueKey<String>(
          '$currentPairKey-${widget.controller.state.range.label}-$_swapVersion',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: RateChart(data: state.data),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart_outlined, size: 48, color: AppTheme.muted),
          const SizedBox(height: 12),
          Text(
            'No chart data available',
            style: AppTheme.body.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: AppTheme.muted),
            const SizedBox(height: 12),
            Text(
              message ?? 'Failed to load chart data',
              style: AppTheme.body.copyWith(color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
