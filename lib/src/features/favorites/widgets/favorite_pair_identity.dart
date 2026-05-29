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
    return Row(
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.border.withValues(alpha: .28),
              width: 1,
            ),
          ),
          child: Center(
            child: CurrencyFlagIcon(
              code: pair.base,
              symbol: CurrencyFlags.forCode(pair.base),
              radius: 11,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 12,
            color: colors.subtle,
          ),
        ),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.border.withValues(alpha: .28),
              width: 1,
            ),
          ),
          child: Center(
            child: CurrencyFlagIcon(
              code: pair.quote,
              symbol: CurrencyFlags.forCode(pair.quote),
              radius: 11,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${pair.base} → ${pair.quote}',
                style: AppTheme.settingsTileTitleStyle(context),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${pair.base}/${pair.quote}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.supportingTextStyle(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
