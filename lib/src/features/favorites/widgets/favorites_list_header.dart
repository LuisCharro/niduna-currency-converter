import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pill_action.dart';
import '../data/favorites_store.dart';

class FavoritesListHeader extends StatelessWidget {
  const FavoritesListHeader({
    required this.count,
    required this.isFull,
    required this.onAdd,
    super.key,
  });

  final int count;
  final bool isFull;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '$count/${FavoritesStore.maxFavorites}',
            style: AppTheme.sectionLabelStyle(context),
          ),
        ),
        if (!isFull)
          PillAction(
            label: l10n(context).favoritesOpenConvert,
            icon: Icons.add_rounded,
            onTap: onAdd,
          ),
      ],
    );
  }
}
