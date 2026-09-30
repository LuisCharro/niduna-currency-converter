import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'dotted_border_box.dart';

/// Dashed "+ Add a pair" row shown after the list while visible pairs are
/// under the effective limit; tapping it opens Convert to pick one.
class FavoritesEmptySlot extends StatelessWidget {
  const FavoritesEmptySlot({required this.onAdd, super.key});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: l10n(context).favoritesAddPairSlot,
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(14),
        child: DottedBorderBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.space4,
              horizontal: AppTheme.space3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add_rounded, size: 18, color: colors.subtle),
                const SizedBox(width: AppTheme.space2),
                Text(
                  l10n(context).favoritesAddPairSlot,
                  style: AppTheme.supportingTextStyle(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
