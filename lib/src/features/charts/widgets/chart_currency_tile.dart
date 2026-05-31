import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class ChartCurrencyTile extends StatelessWidget {
  const ChartCurrencyTile({
    required this.symbol,
    required this.code,
    required this.name,
    required this.isSelected,
    required this.isFixed,
    required this.unlocked,
    required this.tempUnlocked,
    required this.onTap,
    super.key,
  });

  final String symbol;
  final String code;
  final String name;
  final bool isSelected;
  final bool isFixed;
  final bool unlocked;
  final bool tempUnlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !unlocked && !isFixed;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: locked ? .45 : 1,
              child: CurrencyFlagIcon(code: code, symbol: symbol, radius: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: locked
                          ? AppColors.of(context).muted
                          : AppColors.of(context).text,
                    ),
                  ),
                  Text(
                    locked
                        ? tapToUnlockLabel(context)
                        : tempUnlocked
                            ? unlockedFor24hLabel(context)
                            : isFixed
                                ? currentCurrencyLabel(context, code)
                                : name,
                    style: TextStyle(
                      fontSize: 12,
                      color: tempUnlocked
                          ? AppColors.of(context).primary.withValues(alpha: .7)
                          : locked
                              ? AppColors.of(context).muted
                              : isFixed
                                  ? AppColors.of(context).primary
                                      .withValues(alpha: .5)
                                  : AppColors.of(context).subtle,
                    ),
                  ),
                ],
              ),
            ),
            if (isFixed)
              _badge(
                context,
                label: currentBadgeLabel(context),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.of(context).primary.withValues(alpha: .5),
                ),
              )
            else if (tempUnlocked)
              _tempBadge(context)
            else if (isSelected)
              Icon(Icons.check_circle, color: AppColors.of(context).primary)
            else if (unlocked)
              Icon(Icons.chevron_right, color: AppColors.of(context).subtle)
            else
              _badge(
                context,
                icon: Icons.lock_outline,
                label: lockedBadgeLabel(context),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.of(context).muted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
    BuildContext context, {
    IconData? icon,
    required String label,
    required TextStyle style,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: icon != null
            ? AppColors.of(context).container
            : AppColors.of(context).primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: icon != null
              ? AppColors.of(context).border.withValues(alpha: .4)
              : AppColors.of(context).primary.withValues(alpha: .15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.of(context).muted),
            const SizedBox(width: 3),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }

  Widget _tempBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.of(context).primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.of(context).primary.withValues(alpha: .3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.schedule,
            size: 13,
            color: AppColors.of(context).primary,
          ),
          const SizedBox(width: 3),
          Text(
            '24h',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.of(context).primary,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_circle,
              size: 13,
              color: AppColors.of(context).primary,
            ),
          ],
        ],
      ),
    );
  }
}
