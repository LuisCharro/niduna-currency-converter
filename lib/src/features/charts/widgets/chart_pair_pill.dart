import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../../../../l10n/app_localizations_safe.dart';
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
    final largeText = MediaQuery.textScalerOf(context).scale(15) > 17.25;
    final flagRadius = largeText ? 16.0 : chartPairFlagRadius;
    final horizontalPadding = largeText ? 10.0 : AppTheme.space3;
    final contentGap = largeText ? AppTheme.space1 : AppTheme.space2;
    return Material(
      color: AppColors.of(context).container.withValues(alpha: .72),
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      child: Semantics(
        onTapHint: l10n(context).changeChartPairLabel,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.space2,
            ).copyWith(left: horizontalPadding, right: horizontalPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              border: Border.all(
                color: AppColors.of(context).border.withValues(alpha: .14),
              ),
            ),
            child: Row(
              children: <Widget>[
                CurrencyFlagIcon(
                  code: code,
                  symbol: currency.symbol,
                  radius: flagRadius,
                ),
                SizedBox(width: contentGap),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
                if (locked) ...<Widget>[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.of(context).muted,
                  ),
                ],
                if (!tempBadge) ...<Widget>[
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: largeText ? 15 : 17,
                    color: AppColors.of(context).subtle,
                  ),
                ],
                if (tempBadge) ChartTempBadge(compact: narrow),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
