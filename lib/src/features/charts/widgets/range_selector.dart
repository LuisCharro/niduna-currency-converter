import 'package:flutter/material.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartRange.values.map((range) {
          final isSelected = range == selected;
          final isLocked = range.locked && !canUseLockedRanges;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (isLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Intraday ranges coming soon — requires Premium Subscription'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                onChanged(range);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppTheme.border.withValues(alpha: .15)
                      : isSelected
                      ? AppTheme.primary
                      : AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLocked
                        ? AppTheme.border.withValues(alpha: .5)
                        : isSelected
                        ? AppTheme.primary
                        : AppTheme.border.withValues(alpha: .5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (isLocked) ...[
                      Icon(Icons.lock_outline, size: 12, color: AppTheme.muted),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      range.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? AppTheme.muted
                            : isSelected
                            ? Colors.white
                            : AppTheme.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
