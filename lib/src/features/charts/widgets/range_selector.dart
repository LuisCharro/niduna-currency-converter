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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChartRange.values.map((range) {
          final isSelected = range == selected;
          final isLocked = range.locked && !canUseLockedRanges;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.transparent
                      : isSelected
                          ? AppTheme.card
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.transparent),
                  boxShadow: isSelected
                      ? AppTheme.subtleShadow
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                ? AppTheme.text
                                : AppTheme.subtle,
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
