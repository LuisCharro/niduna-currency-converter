import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/theme/app_theme.dart';
import 'presentation/charts_controller.dart';
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

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  void _handleSwap() {
    setState(() => _swapVersion++);
    widget.controller.swapPair();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charts')),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;
          return ListenableBuilder(
            listenable: widget.monetization,
            builder: (context, _) {
              return Column(
                children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: <Widget>[
                    PairSelector(
                      base: state.base,
                      quote: state.quote,
                      onPairChanged: widget.controller.setPair,
                          onSwap: _handleSwap,
                      canSelectAnyPair: widget.monetization.canSelectAnyChartPair,
                      adsEnabled: widget.monetization.adsEnabled,
                    ),
                    if (state.lastUpdated != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Updated ${DateFormat('MMM d').format(state.lastUpdated!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: RangeSelector(
                        selected: state.range,
                        onChanged: widget.controller.setRange,
                        canUseLockedRanges: widget.monetization.canUseIntradayRanges,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildChartArea(state),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ChartSummary(
                  high: state.high,
                  low: state.low,
                  changePercent: state.changePercent,
                ),
              ),
                ],
              );
            },
          );
        },
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final flip = Tween<double>(begin: 0, end: 1).animate(animation);
        return RotationTransition(
          turns: flip,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Padding(
        key: ValueKey<String>('${state.base}-${state.quote}-${state.range.label}-$_swapVersion'),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
        children: <Widget>[
          Icon(Icons.show_chart, size: 48, color: AppTheme.muted),
          const SizedBox(height: 12),
          Text(
            'No chart data available',
            style: TextStyle(fontSize: 15, color: AppTheme.muted),
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
          children: <Widget>[
            Icon(Icons.wifi_off_outlined, size: 48, color: AppTheme.muted),
            const SizedBox(height: 12),
            Text(
              message ?? 'Failed to load chart data',
              style: TextStyle(fontSize: 14, color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
