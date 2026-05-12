import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/chart_range.dart';

class RangeSelector extends StatelessWidget {
  const RangeSelector({
    required this.selected,
    required this.onChanged,
    required this.canUseLockedRanges,
    super.key,
  });

  final ChartRange selected;
  final ValueChanged<ChartRange> onChanged;
  final bool canUseLockedRanges;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.containerHigh.withValues(alpha: .42),
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ChartRange.values.map((range) {
                final isSelected = range == selected;
                final isLocked = range.locked && !canUseLockedRanges;
                return GestureDetector(
                  onTap: () {
                    if (isLocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Intraday ranges coming soon — requires Premium Subscription',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    onChanged(range);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    constraints: const BoxConstraints(minHeight: 34),
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.card : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                      boxShadow: isSelected ? AppTheme.subtleShadow : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLocked) ...[
                          Icon(
                            Icons.lock_outline,
                            size: 12,
                            color: AppTheme.muted,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          range.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isLocked
                                ? AppTheme.muted
                                : isSelected
                                ? AppTheme.text
                                : AppTheme.subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (selected.days > 0)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              _dateSpanLabel(selected),
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  static String _dateSpanLabel(ChartRange range) {
    final from = range.fromDate();
    if (from == null) return '';
    final to = DateTime.now();
    final fmt = DateFormat('d MMM');
    return '${fmt.format(from)} → ${fmt.format(to)}';
  }
}
