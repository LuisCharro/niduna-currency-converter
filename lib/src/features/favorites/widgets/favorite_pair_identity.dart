import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../../../shared/widgets/currency_flags.dart';
import '../domain/favorite_pair.dart';

class FavoritePairIdentity extends StatelessWidget {
  const FavoritePairIdentity({required this.pair, super.key});

  final FavoritePair pair;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: .32),
                  width: 1,
                ),
              ),
              child: Center(
                child: CurrencyFlagIcon(
                  code: pair.base,
                  symbol: CurrencyFlags.forCode(pair.base),
                  radius: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: colors.muted,
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: .32),
                  width: 1,
                ),
              ),
              child: Center(
                child: CurrencyFlagIcon(
                  code: pair.quote,
                  symbol: CurrencyFlags.forCode(pair.quote),
                  radius: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '${pair.base} → ${pair.quote}',
                style: AppTheme.settingsTileTitleStyle(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space1),
        Text(
          '${pair.base}/${pair.quote}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.supportingTextStyle(context),
        ),
      ],
    );
  }
}
