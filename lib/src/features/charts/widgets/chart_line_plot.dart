import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class ChartLinePlot extends StatelessWidget {
  const ChartLinePlot({
    required this.spots,
    required this.dates,
    required this.minY,
    required this.maxY,
    required this.lineColor,
    required this.touchedIndex,
    required this.onTouch,
    required this.touchSpotThreshold,
    super.key,
  });

  final List<FlSpot> spots;
  final List<DateTime> dates;
  final double minY;
  final double maxY;
  final Color lineColor;
  final int? touchedIndex;
  final BaseTouchCallback<LineTouchResponse> onTouch;
  final double touchSpotThreshold;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.of(context).card.withValues(alpha: .18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        LineChart(
          LineChartData(
            minX: spots.first.x - .25,
            maxX: spots.last.x + .25,
            minY: minY,
            maxY: maxY,
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: false,
              touchSpotThreshold: touchSpotThreshold,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 0,
                getTooltipItems: (_) => [],
              ),
              touchCallback: onTouch,
              getTouchedSpotIndicator: (barData, spotIndexes) {
                final cardColor = AppColors.of(context).card;
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: lineColor.withValues(alpha: .72),
                      strokeWidth: 2.4,
                      dashArray: [5, 4],
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5.5,
                          color: cardColor,
                          strokeWidth: 3.2,
                          strokeColor: lineColor,
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 2,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.of(context).border.withValues(alpha: .1),
                strokeWidth: .5,
                dashArray: [5, 5],
              ),
            ),
            extraLinesData: const ExtraLinesData(),
            titlesData: _titlesData(context),
            borderData: FlBorderData(show: false),
            lineBarsData: <LineChartBarData>[
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                preventCurveOverShooting: true,
                color: lineColor,
                barWidth: 2.8,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  checkToShowDot: (spot, barData) => spot.x == spots.last.x,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 2.8,
                      color: lineColor.withValues(alpha: .72),
                      strokeWidth: 0,
                    );
                  },
                ),
                showingIndicators: touchedIndex == null
                    ? const <int>[]
                    : <int>[touchedIndex!],
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      lineColor.withValues(alpha: .18),
                      lineColor.withValues(alpha: .02),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  FlTitlesData _titlesData(BuildContext context) {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: 1,
          minIncluded: false,
          maxIncluded: false,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (value != index.toDouble() || !_labelIndexes().contains(index)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                DateFormat('d MMM').format(dates[index]),
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.of(context).muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Set<int> _labelIndexes() {
    final count = dates.length;
    if (count == 0) return const <int>{};
    if (count <= 8) return List<int>.generate(count, (index) => index).toSet();

    final section = (count - 1) / 6;
    return <int>{
      section.round(),
      (section * 2).round(),
      (section * 3).round(),
      (section * 4).round(),
      (section * 5).round(),
    };
  }
}
