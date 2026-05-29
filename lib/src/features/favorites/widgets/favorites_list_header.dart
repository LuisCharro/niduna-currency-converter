import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_theme.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../../convert/domain/rate_freshness.dart';
import '../../../shared/widgets/pill_action.dart';

class FavoritesListHeader extends StatelessWidget {
  const FavoritesListHeader({
    required this.count,
    required this.maxLimit,
    required this.visibleCount,
    required this.isAtLimit,
    required this.snapshot,
    required this.onAdd,
    super.key,
  });

  final int count;
  final int maxLimit;
  final int visibleCount;
  final bool isAtLimit;
  final LatestRatesSnapshot? snapshot;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final freshness = _freshnessLabel();
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '$visibleCount PAIRS',
                style: AppTheme.sectionLabelStyle(context),
              ),
            ),
            if (!isAtLimit)
              Semantics(
                button: true,
                label: l10n(context).favoritesOpenConvert,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAdd();
                  },
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  child: PillAction(
                    label: l10n(context).favoritesOpenConvert,
                    icon: Icons.add_rounded,
                    onTap: onAdd,
                    emphasized: true,
                  ),
                ),
              ),
          ],
        ),
        if (freshness != null) ...<Widget>[
          const SizedBox(height: AppTheme.space2),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  freshness,
                  style: AppTheme.supportingTextStyle(context),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String? _freshnessLabel() {
    final data = snapshot;
    if (data == null) return null;
    return RateFreshness.updatedLabel(
      rateDate: data.date,
      savedAt: data.savedAt,
    );
  }
}
