import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Rates ledger header with light Edit affordance (D2-CON-5).
class RatesSectionHeader extends StatelessWidget {
  const RatesSectionHeader({
    required this.onEdit,
    this.compact = false,
    super.key,
  });

  final VoidCallback onEdit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final verticalPad = compact ? AppTheme.space1 : AppTheme.space2;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        verticalPad,
        AppTheme.pagePadding,
        verticalPad,
      ),
      child: Row(
        children: <Widget>[
          Text(
            ratesSectionLabel(context),
            style: AppTheme.sectionLabel.copyWith(color: colors.muted),
          ),
          const Spacer(),
          OutlinedButton.icon(
            key: const Key('open_currency_picker'),
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              backgroundColor: colors.container.withValues(alpha: .64),
              side: BorderSide(color: colors.border.withValues(alpha: .16)),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space3,
                vertical: 7,
              ),
              minimumSize: const Size(48, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 17),
            label: Text(
              l10n?.btnAdd ?? 'Add currencies',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
