import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/clamped_text_scale.dart';
import 'chart_theme_text.dart';
import 'chart_value_formatter.dart';

class ChartTouchOverlay extends StatelessWidget {
  const ChartTouchOverlay({
    required this.date,
    required this.currencyCode,
    required this.value,
    required this.baseValue,
    required this.lineColor,
    this.compact = false,
    super.key,
  });

  final DateTime date;
  final String currencyCode;
  final double value;
  final double baseValue;
  final Color lineColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final changePercent = baseValue != 0
        ? ((value - baseValue) / baseValue.abs()) * 100
        : 0.0;
    final absoluteChange = value - baseValue;
    final isPositiveChange = changePercent >= 0;
    final trendColor = isPositiveChange
        ? AppColors.of(context).trendUp
        : AppColors.of(context).trendDown;
    final arrow = isPositiveChange ? '\u2191' : '\u2193';
    final sign = absoluteChange > 0
        ? '+'
        : absoluteChange < 0
        ? '−'
        : '';

    final identity = <Widget>[
      Text(
        DateFormat('EEE d MMM yyyy').format(date).toUpperCase(),
        style: ChartThemeText.micro(context, color: lineColor),
      ),
      const SizedBox(height: 3),
      Text(
        '${formatChartValue(value)} $currencyCode',
        style: ChartThemeText.frauncesValue(context),
      ),
    ];
    final percent = Text(
      '$arrow ${changePercent.abs().toStringAsFixed(2)}%',
      style: ChartThemeText.caption(
        context,
        color: trendColor,
      ).copyWith(fontSize: 12.5, fontWeight: FontWeight.w800),
    );
    final delta = Text(
      '$sign${formatChartValue(absoluteChange.abs())} $currencyCode',
      style: ChartThemeText.caption(context),
    );
    final content = compact
        ? Wrap(
            spacing: 24,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: identity,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [percent, const SizedBox(height: 3), delta],
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...identity,
              const SizedBox(height: 1),
              Wrap(spacing: 8, children: [percent, delta]),
            ],
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.of(context).card.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor.withValues(alpha: .14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.of(context).border.withValues(alpha: .12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: ClampedTextScale(
          maxScaleFactor: 1.3,
          child: compact ? SingleChildScrollView(child: content) : content,
        ),
      ),
    );
  }
}
