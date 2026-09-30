import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/toolbar_icon_button.dart';
import '../../../shared/widgets/toolbar_pill.dart';

/// Round toolbar pill with a single refresh action, same chrome as Convert's
/// amount-card toolbar.
class FavoritesToolbarPill extends StatelessWidget {
  const FavoritesToolbarPill({required this.onRefresh, super.key});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return ToolbarPill(
      children: <Widget>[
        ToolbarIconButton(
          iconKey: const Key('favorites_refresh'),
          tooltip: l10n(context).refreshRatesTooltip,
          icon: Icons.sync_rounded,
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
