import 'package:flutter/material.dart';

import '../../../shared/widgets/value_pill.dart';
import '../domain/favorite_pair_rate.dart';

class FavoriteRateText extends StatelessWidget {
  const FavoriteRateText({required this.rate, super.key});

  final double? rate;

  @override
  Widget build(BuildContext context) {
    // Compact: less internal padding keeps the gap to the trend line below
    // it tight, rather than reading as a big empty gap under the pill.
    return ValuePill(
      text: rate == null ? '—' : formatFavoriteRate(rate!),
      compact: true,
    );
  }
}
