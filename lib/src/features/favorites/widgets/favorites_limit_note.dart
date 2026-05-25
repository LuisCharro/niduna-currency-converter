import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class FavoritesLimitNote extends StatelessWidget {
  const FavoritesLimitNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: <Widget>[
        Icon(Icons.lock_outline_rounded, size: 16, color: colors.primary),
        const SizedBox(width: AppTheme.space2),
        Expanded(
          child: Text(
            l10n(context).favoritesLimitMessage,
            style: AppTheme.supportingTextStyle(context),
          ),
        ),
      ],
    );
  }
}
