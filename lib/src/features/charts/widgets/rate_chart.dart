import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class RateChart extends StatefulWidget {
  const RateChart({required this.data, super.key});

  final Map<DateTime, double> data;

  @override
  State<RateChart> createState() => _RateChartState();
}

class _RateChartState extends State<RateChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drawController;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant RateChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mapEquals(oldWidget.data, widget.data)) {
      _drawController.reset();
      _drawController.forward();
      _touchedIndex = null;
    }
  }

  @override
  void dispose() {
    _drawController.dispose();
    super.dispose();
  }

  bool _mapEquals(Map<DateTime, double> a, Map<DateTime, double> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

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

  double get _dataMin => widget.data.values.reduce(math.min);

  double get _dataMax => widget.data.values.reduce(math.max);

  double? get _minY {
    if (widget.data.isEmpty) return null;
    final range = _dataMax - _dataMin;
    return _dataMin - range * 0.08;
  }

  double? get _maxY {
    if (widget.data.isEmpty) return null;
    final range = _dataMax - _dataMin;
    return _dataMax + range * 0.08;
  }

  List<DateTime> get _sortedDates {
    final entries = widget.data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => e.key).toList();
  }

  void _handleTouchEnd() {
    setState(() => _touchedIndex = null);
  }

  void _handleTouchSet(LineTouchResponse? response) {
    final index = response?.lineBarSpots?.first.x.toInt();
    final spots = _spots;
    if (index != null && index >= 0 && index < spots.length) {
      setState(() => _touchedIndex = index);
    }
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
    final lineColor = isPositive ? AppTheme.trendUp : AppTheme.trendDown;
    final openPrice = spots.first.y;

    return AnimatedBuilder(
      animation: _drawController,
      builder: (context, _) {
        final progress = Curves.easeOut.transform(_drawController.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Stack(
              children: <Widget>[
                LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        tooltipMargin: 0,
                        getTooltipItems: (_) => [],
                      ),
                      touchCallback: (event, response) {
                        if (event is FlPanUpdateEvent ||
                            event is FlLongPressMoveUpdate) {
                          _handleTouchSet(response);
                        } else if (event is FlPanEndEvent ||
                            event is FlLongPressEnd ||
                            event is FlTapCancelEvent) {
                          _handleTouchEnd();
                        }
                      },
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: lineColor.withValues(alpha: .35),
                              strokeWidth: 1.2,
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: AppTheme.card,
                                  strokeWidth: 2.5,
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
                        color: AppTheme.border.withValues(alpha: .12),
                        strokeWidth: .5,
                        dashArray: [4, 4],
                      ),
                    ),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: openPrice,
                          color: AppTheme.subtle.withValues(alpha: .35),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                        ),
                      ],
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
                          reservedSize: 24,
                          interval: math.max(
                            1,
                            (spots.length / 5).roundToDouble(),
                          ),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= sortedDates.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                DateFormat('d MMM').format(sortedDates[index]),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.subtle,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        preventCurveOverShooting: true,
                        color: lineColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              lineColor.withValues(alpha: .18),
                              lineColor.withValues(alpha: .02),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_touchedIndex != null &&
                    _touchedIndex! < sortedDates.length)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 12,
                          right: 12,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _TouchOverlay(
                            date: sortedDates[_touchedIndex!],
                            value: spots[_touchedIndex!].y,
                            baseValue: spots.first.y,
                            lineColor: lineColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.subtle.withValues(alpha: .2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          openPrice.toStringAsFixed(4),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Fraunces',
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OPEN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.subtle,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TouchOverlay extends StatelessWidget {
  const _TouchOverlay({
    required this.date,
    required this.value,
    required this.baseValue,
    required this.lineColor,
  });

  final DateTime date;
  final double value;
  final double baseValue;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final changePercent = baseValue != 0
        ? ((value - baseValue) / baseValue.abs()) * 100
        : 0.0;
    final absoluteChange = value - baseValue;
    final isPositiveChange = changePercent >= 0;
    final trendColor = isPositiveChange ? AppTheme.trendUp : AppTheme.trendDown;
    final arrow = isPositiveChange ? '\u2191' : '\u2193';
    final sign = isPositiveChange ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat('d MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: lineColor,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.toStringAsFixed(4),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.text,
              fontFamily: 'Fraunces',
              letterSpacing: -0.3,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$arrow ${changePercent.abs().toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: trendColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$sign${absoluteChange.abs().toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
