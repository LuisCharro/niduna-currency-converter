import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
      child: Row(
        children: ChartRange.values.map((range) {
          final isSelected = range == selected;
          final isLocked = range.locked && !canUseLockedRanges;
          final isCryptoUnavailable = includesCrypto && !range.supportsCrypto;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                if (isLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(intradayPremiumMessage(context)),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                if (isCryptoUnavailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(cryptoRangeLimitMessage(context)),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                onChanged(range);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.of(context).card : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.of(context).border.withValues(alpha: .14)
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  boxShadow: isSelected ? AppTheme.subtleShadowFor(context) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLocked) ...[
                      Icon(Icons.lock_outline, size: 12, color: AppColors.of(context).muted),
                      const SizedBox(width: 4),
                    ] else if (isCryptoUnavailable) ...[
                      Icon(Icons.block, size: 12, color: AppColors.of(context).muted),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      chartRangeLabel(context, range.label),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLocked || isCryptoUnavailable
                            ? AppColors.of(context).muted
                            : isSelected
                            ? AppColors.of(context).text
                            : AppColors.of(context).subtle,
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
