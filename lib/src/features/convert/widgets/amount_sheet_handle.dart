import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AmountSheetHandle extends StatelessWidget {
  const AmountSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.border.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const SizedBox(width: 44, height: 4),
      ),
    );
  }
}
