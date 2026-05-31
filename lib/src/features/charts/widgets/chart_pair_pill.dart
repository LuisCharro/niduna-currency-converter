import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import 'chart_temp_badge.dart';

const double chartPairFlagRadius = 18;

class ChartPairPill extends StatelessWidget {
  const ChartPairPill({
    required this.code,
    required this.onTap,
    required this.locked,
    required this.tempBadge,
    super.key,
  });

  final String code;
  final VoidCallback onTap;
  final bool locked;
  final bool tempBadge;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(code);
    final narrow = MediaQuery.sizeOf(context).width < 380;
    return Material(
      color: AppColors.of(context).container.withValues(alpha: .72),
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space3,
            vertical: AppTheme.space2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            border: Border.all(color: AppColors.of(context).border.withValues(alpha: .14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CurrencyFlagIcon(
                        code: code,
                        symbol: currency.symbol,
                        radius: chartPairFlagRadius,
                      ),
                      const SizedBox(width: AppTheme.space2),
                      Flexible(
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      if (locked) ...<Widget>[
                        const SizedBox(width: 4),
                        Icon(Icons.lock_outline, size: 14, color: AppColors.of(context).muted),
                      ],
                      if (!tempBadge) ...<Widget>[
                        const SizedBox(width: 2),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 17,
                          color: AppColors.of(context).subtle,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (tempBadge)
                ChartTempBadge(compact: narrow),
            ],
          ),
        ),
      ),
    );
  }
}
