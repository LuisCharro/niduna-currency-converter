import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'favorites_swipe_hint_row.dart';
import 'favorites_swipe_pin_action.dart';

class FavoritesSwipeHint extends StatelessWidget {
  const FavoritesSwipeHint({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 58,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: FavoritesSwipePinAction(colors: colors),
            ),
          ),
          Positioned(
            left: 0,
            right: 92,
            top: 0,
            bottom: 0,
            child: FavoritesSwipeHintRow(colors: colors),
          ),
        ],
      ),
    );
  }
}
