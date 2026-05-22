import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/chart_range.dart';

class RangeSelector extends StatelessWidget {
  const RangeSelector({
    required this.selected,
    required this.onChanged,
    required this.canUseLockedRanges,
    required this.includesCrypto,
    super.key = const Key('charts_range_selector'),
  });

  final ChartRange selected;
  final ValueChanged<ChartRange> onChanged;
  final bool canUseLockedRanges;
  final bool includesCrypto;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.containerHigh.withValues(alpha: .36),
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
            final isCryptoUnavailable = includesCrypto && !range.supportsCrypto;
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
                if (isCryptoUnavailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Crypto charts support up to 1Y with no-key providers',
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
                constraints: const BoxConstraints(minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.card : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.border.withValues(alpha: .12)
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  boxShadow: isSelected ? AppTheme.subtleShadow : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLocked) ...[
                      Icon(Icons.lock_outline, size: 12, color: AppTheme.muted),
                      const SizedBox(width: 4),
                    ] else if (isCryptoUnavailable) ...[
                      Icon(Icons.block, size: 12, color: AppTheme.muted),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      range.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLocked || isCryptoUnavailable
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
    );
  }
}
