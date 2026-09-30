import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/toolbar_icon_button.dart';
import '../../../shared/widgets/toolbar_pill.dart';

class AmountUtilityPill extends StatelessWidget {
  const AmountUtilityPill({
    required this.onRefresh,
    required this.onShare,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final VoidCallback? onShare;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return ToolbarPill(
      children: <Widget>[
        ToolbarIconButton(
          iconKey: const Key('convert_refresh'),
          tooltip: loc.refreshRatesTooltip,
          icon: Icons.sync_rounded,
          onPressed: onRefresh,
        ),
        const ToolbarDivider(),
        ToolbarIconButton(
          iconKey: const Key('convert_share'),
          tooltip: loc.shareRatesTooltip,
          icon: Icons.ios_share_rounded,
          onPressed: onShare,
        ),
        const ToolbarDivider(),
        ToolbarIconButton(
          tooltip: loc.openSettingsTooltip,
          icon: Icons.tune_rounded,
          onPressed: onMore,
        ),
      ],
    );
  }
}
