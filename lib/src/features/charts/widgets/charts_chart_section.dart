import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/chart_range.dart';
import '../presentation/chart_state.dart';
import 'charts_empty_state.dart';
import 'charts_error_state.dart';
import 'range_selector.dart';
import 'rate_chart.dart';

class ChartsChartSection extends StatelessWidget {
  const ChartsChartSection({
    required this.state,
    required this.onRangeChanged,
    required this.canUseLockedRanges,
    required this.onRetry,
    required this.swapVersion,
    required this.lastPairKey,
    required this.onSwapSettled,
    this.compact = false,
    super.key,
  });

  final ChartState state;
  final ValueChanged<ChartRange> onRangeChanged;
  final bool canUseLockedRanges;
  final VoidCallback onRetry;
  final int swapVersion;
  final String lastPairKey;
  final ValueChanged<String> onSwapSettled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final loading = state.status == ChartStatus.loading && state.data.isEmpty;

    return Padding(
      padding: AppTheme.pageInsets.copyWith(top: compact ? 0 : AppTheme.space1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.of(context).border.withValues(alpha: .1),
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.of(context).container,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.of(context).border.withValues(alpha: .1),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  compact ? 4 : 6,
                  0,
                  compact ? 4 : 6,
                ),
                child: RangeSelector(
                  selected: state.range,
                  onChanged: onRangeChanged,
                  canUseLockedRanges: canUseLockedRanges,
                  includesCrypto: state.includesCrypto,
                ),
              ),
            ),
            if (loading)
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                color: AppColors.of(context).trendUp.withValues(alpha: .7),
              ),
            Expanded(child: _buildPlot(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlot(BuildContext context) {
    if (state.status == ChartStatus.loading && state.data.isEmpty) {
      return const SizedBox.shrink();
    }

    if (state.status == ChartStatus.error && state.data.isEmpty) {
      return ChartsErrorState(message: state.message, onRetry: onRetry);
    }

    if (state.data.isEmpty) {
      return const ChartsEmptyState();
    }

    final currentPairKey = '${state.base}-${state.quote}';
    final isSwap =
        lastPairKey.isNotEmpty &&
        lastPairKey != currentPairKey &&
        swapVersion > 0;

    if (isSwap) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSwapSettled(currentPairKey);
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
        return FadeTransition(opacity: animation, child: child);
      },
      child: Padding(
        key: ValueKey<String>(
          '$currentPairKey-${state.range.label}-$swapVersion',
        ),
        padding: EdgeInsets.only(top: compact ? 0 : 2, bottom: compact ? 0 : 4),
        child: SizedBox.expand(
          child: RateChart(
            data: state.data,
            currencySymbol: currencyByCode(state.base).symbol,
          ),
        ),
      ),
    );
  }
}
