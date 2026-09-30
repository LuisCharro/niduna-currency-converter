import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'currency_flag_icon.dart';
import 'currency_flags.dart';

/// Two currency flags overlapping (base in front, quote peeking out behind),
/// used by Favorites' hero card, rows and empty state.
class OverlappingFlagPair extends StatelessWidget {
  const OverlappingFlagPair({
    required this.base,
    required this.quote,
    this.size = 32,
    super.key,
  });

  final String base;
  final String quote;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final overlap = size * 0.62;
    return SizedBox(
      width: size + overlap,
      height: size,
      child: Stack(
        children: <Widget>[
          Positioned(left: overlap, child: _flag(colors, quote, size)),
          Positioned(left: 0, child: _flag(colors, base, size)),
        ],
      ),
    );
  }

  Widget _flag(AppColors colors, String code, double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.bg,
        border: Border.all(color: colors.border.withValues(alpha: .32)),
      ),
      child: Center(
        child: CurrencyFlagIcon(
          code: code,
          symbol: CurrencyFlags.forCode(code),
          radius: diameter * 0.42,
        ),
      ),
    );
  }
}
