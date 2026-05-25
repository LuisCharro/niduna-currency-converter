import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/rates/provider_config.dart';
import '../../../core/theme/app_theme.dart';
import '../presentation/charts_controller.dart';
import 'chart_header.dart';
import 'chart_metric_rail.dart';
import 'chart_pair_strip.dart';
import 'charts_chart_section.dart';

class ChartsTabBody extends StatefulWidget {
  const ChartsTabBody({
    required this.controller,
    required this.monetization,
    super.key,
  });

  final ChartsController controller;
  final MonetizationController monetization;

  @override
  State<ChartsTabBody> createState() => _ChartsTabBodyState();
}

class _ChartsTabBodyState extends State<ChartsTabBody> {
  int _swapVersion = 0;
  String _lastPairKey = '';

  void _handleSwap() {
    setState(() {
      _swapVersion++;
      _lastPairKey =
          '${widget.controller.state.quote}-${widget.controller.state.base}';
    });
    widget.controller.swapPair();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 720;
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
            Expanded(
              child: ChartsChartSection(
                state: state,
                onRangeChanged: widget.controller.setRange,
                canUseLockedRanges: widget.monetization.canUseIntradayRanges,
                onRetry: widget.controller.load,
                swapVersion: _swapVersion,
                lastPairKey: _lastPairKey,
                onSwapSettled: (key) => setState(() => _lastPairKey = key),
                compact: compact,
              ),
            ),
            ChartPairStrip(
              base: state.base,
              quote: state.quote,
              allowCryptoCharts: ProviderConfig.cryptoChartsEnabled,
              onPairChanged: widget.controller.setPair,
              onSwap: _handleSwap,
              controller: widget.monetization,
              compact: compact,
            ),
            Padding(
              padding: AppTheme.pageInsets.copyWith(
                bottom: compact ? AppTheme.space1 : AppTheme.space2,
              ),
              child: ChartMetricRail(
                high: state.high,
                low: state.low,
                changePercent: state.changePercent,
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }
}
