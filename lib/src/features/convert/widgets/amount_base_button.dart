import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class AmountBaseButton extends StatelessWidget {
  const AmountBaseButton({
    required this.base,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final String base;
  final VoidCallback onTap;
  final bool compact;

  static double estimatedWidth({bool compact = false}) {
    return compact ? 92 : 108;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final currency = currencyByCode(base);
    final minHeight = compact ? 44.0 : 48.0;
    final minWidth = compact ? 72.0 : 76.0;
    final horizontalPadding = compact ? 10.0 : 12.0;
    final verticalPadding = compact ? 6.0 : 8.0;
    final endPadding = compact ? 8.0 : 10.0;
    final flagRadius = compact ? 15.0 : 17.0;
    final codeFontSize = compact ? 14.0 : 15.0;
    final iconSize = compact ? 16.0 : 17.0;
    return Semantics(
      button: true,
      label: l10n(context).changeBaseCurrencyLabel(base),
      child: Material(
        color: colors.card.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: InkWell(
          key: const Key('open_base_currency_picker'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Container(
              key: ValueKey<String>(base),
              constraints: BoxConstraints(minHeight: minHeight, minWidth: minWidth),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                endPadding,
                verticalPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                border: Border.all(color: colors.border.withValues(alpha: .16)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CurrencyFlagIcon(
                    code: base,
                    symbol: currency.symbol,
                    radius: flagRadius,
                  ),
                  SizedBox(width: compact ? 5 : 6),
                  Text(
                    base,
                    style: TextStyle(
                      fontSize: codeFontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: iconSize,
                    color: colors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
