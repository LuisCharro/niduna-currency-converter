import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pill_action.dart';

class FavoritesListHeader extends StatelessWidget {
  const FavoritesListHeader({
    required this.count,
    required this.maxLimit,
    required this.visibleCount,
    required this.isAtLimit,
    required this.onAdd,
    super.key,
  });

  final int count;
  final int maxLimit;
  final int visibleCount;
  final bool isAtLimit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '$visibleCount/$maxLimit',
            style: AppTheme.sectionLabelStyle(context),
          ),
        ),
        if (!isAtLimit)
          PillAction(
            label: l10n(context).favoritesOpenConvert,
            icon: Icons.add_rounded,
            onTap: onAdd,
          ),
      ],
    );
  }
}
