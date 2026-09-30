import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/screen_title.dart';
import 'favorites_toolbar_pill.dart';

/// "Favorites" title + refresh toolbar pill (mirrors Convert's header row).
class FavoritesHeaderRow extends StatelessWidget {
  const FavoritesHeaderRow({required this.onRefresh, super.key});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ScreenTitle(l10n(context).tabFavorites),
        const Spacer(),
        FavoritesToolbarPill(onRefresh: onRefresh),
      ],
    );
  }
}
