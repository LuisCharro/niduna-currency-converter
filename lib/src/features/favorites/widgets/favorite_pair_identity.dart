import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../../../shared/widgets/currency_flags.dart';
import '../domain/favorite_pair.dart';

class FavoritePairIdentity extends StatelessWidget {
  const FavoritePairIdentity({required this.pair, super.key});

  static const double _iconSize = 32;
  static const double _iconRadius = 14;

  final FavoritePair pair;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: _iconSize,
          height: _iconSize,
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
              radius: _iconRadius,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 15,
            color: colors.subtle,
          ),
        ),
        Container(
          width: _iconSize,
          height: _iconSize,
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
              radius: _iconRadius,
            ),
          ),
        ),
      ],
    );
  }
}
