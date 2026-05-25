import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'floating_pill_nav_bar.dart';

class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom =
        AppTheme.floatingNavBottomOffset + MediaQuery.paddingOf(context).bottom;
    final items = <({IconData icon, String label})>[
      (icon: Icons.swap_horiz_rounded, label: l10n?.tabConvert ?? "Convert"),
      (icon: Icons.star_rounded, label: l10n?.tabFavorites ?? "Favorites"),
      (icon: Icons.show_chart_rounded, label: l10n?.tabCharts ?? "Chart"),
      (icon: Icons.settings_rounded, label: l10n?.tabSettings ?? "Settings"),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 370),
          child: FloatingPillNavBar(
            items: items,
            selectedIndex: selectedIndex,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
