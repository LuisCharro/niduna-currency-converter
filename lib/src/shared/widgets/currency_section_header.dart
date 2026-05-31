import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/currency/currency_groups.dart';

class CurrencySectionHeader extends StatelessWidget {
  const CurrencySectionHeader({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  final CurrencyGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
              size: 20,
              color: colors.muted,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                '${group.section.label} (${group.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.muted,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
