import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'chart_line_plot.dart';
import 'chart_touch_overlay.dart';

class RateChart extends StatefulWidget {
  const RateChart({
    required this.data,
    required this.currencySymbol,
    super.key,
  });

  final Map<DateTime, double> data;
  final String currencySymbol;

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
    final padding = range == 0 ? _dataMin.abs() * 0.01 + .0001 : range * 0.1;
    return _dataMin - padding;
  }

  double? get _maxY {
    if (widget.data.isEmpty) return null;
    final range = _dataMax - _dataMin;
    final padding = range == 0 ? _dataMax.abs() * 0.01 + .0001 : range * 0.1;
    return _dataMax + padding;
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

  double _touchThreshold(int spotCount) => spotCount <= 10 ? 44 : 22;

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

    return AnimatedBuilder(
      animation: _drawController,
      builder: (context, _) {
        final progress = Curves.easeOut.transform(_drawController.value);
        return Opacity(
          opacity: progress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Stack(
              children: <Widget>[
                ChartLinePlot(
                spots: spots,
                dates: sortedDates,
                minY: minY,
                maxY: maxY,
                lineColor: lineColor,
                touchedIndex: _touchedIndex,
                touchSpotThreshold: _touchThreshold(spots.length),
                onTouch: _handleTouch,
              ),
                if (_touchedIndex != null && _touchedIndex! < sortedDates.length)
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
                          child: ChartTouchOverlay(
                            date: sortedDates[_touchedIndex!],
                            currencySymbol: widget.currencySymbol,
                            value: spots[_touchedIndex!].y,
                            baseValue: spots.first.y,
                            lineColor: lineColor,
                          ),
                        ),
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

  void _handleTouch(FlTouchEvent event, LineTouchResponse? response) {
    if (event is FlPanDownEvent ||
        event is FlPanStartEvent ||
        event is FlPanUpdateEvent ||
        event is FlTapDownEvent ||
        event is FlLongPressStart ||
        event is FlLongPressMoveUpdate) {
      _handleTouchSet(response);
    } else if (event is FlPanEndEvent ||
        event is FlPanCancelEvent ||
        event is FlLongPressEnd ||
        event is FlTapCancelEvent) {
      _handleTouchEnd();
    }
  }
}
