import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_theme.dart';

/// "MORE PAIRS · N OF M" small-caps label above the rows that follow the
/// hero card (mirrors Convert's "RATES" section label).
class FavoritesSectionHeader extends StatelessWidget {
  const FavoritesSectionHeader({
    required this.visibleCount,
    required this.effectiveLimit,
    super.key,
  });

  final int visibleCount;
  final int effectiveLimit;

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n(context).favoritesMorePairsHeader(effectiveLimit, visibleCount),
      style: AppTheme.sectionLabelStyle(context),
    );
  }
}
