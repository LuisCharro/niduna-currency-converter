import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class RateChart extends StatefulWidget {
  const RateChart({
    required this.data,
    super.key,
  });

  final Map<DateTime, double> data;

  @override
  State<RateChart> createState() => _RateChartState();
}

class _RateChartState extends State<RateChart> {
  int? _touchedIndex;

  List<FlSpot> get _spots {
    final sorted = widget.data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  bool get _isPositive {
    final sorted = widget.data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (sorted.length < 2) return true;
    return sorted.last.value >= sorted.first.value;
  }

  double? get _minY {
    if (widget.data.isEmpty) return null;
    final values = widget.data.values.toList();
    final min = values.reduce(math.min);
    final range = values.reduce(math.max) - min;
    return min - range * 0.08;
  }

  double? get _maxY {
    if (widget.data.isEmpty) return null;
    final values = widget.data.values.toList();
    final max = values.reduce(math.max);
    final range = max - values.reduce(math.min);
    return max + range * 0.08;
  }

  List<DateTime> get _sortedDates {
    final entries = widget.data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => e.key).toList();
  }

  double? _firstRate() {
    if (widget.data.isEmpty) return null;
    final sorted = widget.data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.first.value;
  }

  double? _changeFromFirst(double currentRate) {
    final first = _firstRate();
    if (first == null || first == 0) return null;
    return ((currentRate - first) / first) * 100;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = _spots;
    final sortedDates = _sortedDates;
    final minY = _minY!;
    final maxY = _maxY!;
    final isPositive = _isPositive;
    final upColor = const Color(0xFF34C759);
    final downColor = const Color(0xFFFF3B30);
    final lineColor = isPositive ? upColor : downColor;

    return Column(
      children: <Widget>[
        SizedBox(
          height: 48,
          child: _touchedIndex != null && _touchedIndex! < sortedDates.length
              ? _TooltipCard(
                  date: sortedDates[_touchedIndex!],
                  rate: spots[_touchedIndex!].y,
                  changeFromFirst: _changeFromFirst(spots[_touchedIndex!].y),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppTheme.border.withValues(alpha: .3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: math.max(1, (spots.length / 4).roundToDouble()),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= sortedDates.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('MMM d').format(sortedDates[index]),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.muted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (touchedSpot) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((_) => null).toList(),
                ),
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent || event is FlLongPressStart) {
                    final index = response?.lineBarSpots?.first.x.toInt();
                    if (index != null && index >= 0 && index < spots.length) {
                      setState(() => _touchedIndex = index);
                    }
                  } else if (event is FlPanUpdateEvent || event is FlLongPressMoveUpdate) {
                    final index = response?.lineBarSpots?.first.x.toInt();
                    if (index != null && index >= 0 && index < spots.length) {
                      setState(() => _touchedIndex = index);
                    }
                  } else if (event is FlTapCancelEvent || event is FlLongPressEnd) {
                    setState(() => _touchedIndex = null);
                  }
                },
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    final isSelected = _touchedIndex == index;
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: AppTheme.muted.withValues(alpha: .4),
                        strokeWidth: isSelected ? 1.5 : 1,
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: isSelected ? 6 : 3,
                            color: isSelected ? lineColor : lineColor.withValues(alpha: .5),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  preventCurveOverShooting: true,
                  color: lineColor,
                  barWidth: 2.2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        lineColor.withValues(alpha: 0.25),
                        lineColor.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    required this.date,
    required this.rate,
    required this.changeFromFirst,
  });

  final DateTime date;
  final double rate;
  final double? changeFromFirst;

  @override
  Widget build(BuildContext context) {
    final isPositive = changeFromFirst != null && changeFromFirst! >= 0;
    final changeColor = isPositive
        ? const Color(0xFF34C759)
        : const Color(0xFFFF3B30);
    final arrow = changeFromFirst == null
        ? ''
        : isPositive
            ? '▲'
            : '▼';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border.withValues(alpha: .5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            DateFormat('d MMM').format(date),
            style: TextStyle(fontSize: 13, color: AppTheme.muted),
          ),
          const SizedBox(width: 16),
          Text(
            rate.toStringAsFixed(4),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
          if (changeFromFirst != null) ...[
            const SizedBox(width: 12),
            Text(
              '$arrow ${changeFromFirst!.abs().toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: changeColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}