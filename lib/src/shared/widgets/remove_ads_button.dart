import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Coral Remove Ads link aligned under the banner (M2-2).
class RemoveAdsButton extends StatelessWidget {
  const RemoveAdsButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space5,
        AppTheme.space1,
        AppTheme.space5,
        AppTheme.space2,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.coralInk,
            backgroundColor: colors.coralSurface.withValues(alpha: .85),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space4,
              vertical: AppTheme.space2,
            ),
            minimumSize: const Size(48, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            ),
          ),
          child: const Text(
            'Remove ads',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
