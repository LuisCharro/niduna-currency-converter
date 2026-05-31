import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AmountDoneButton extends StatelessWidget {
  const AmountDoneButton({required this.isDirty, required this.onTap, super.key});

  final bool isDirty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: isDirty ? colors.primary : colors.primary.withValues(alpha: .82),
        foregroundColor: colors.card.withValues(alpha: isDirty ? 1 : .94),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      child: Text(l10n?.btnDone ?? 'Done'),
    );
  }
}
