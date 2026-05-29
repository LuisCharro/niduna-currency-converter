import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../../../shared/widgets/currency_flags.dart';
import '../../convert/domain/latest_rates_snapshot.dart';
import '../domain/favorite_pair.dart';
import '../domain/favorite_pair_rate.dart';
import 'favorite_pair_identity.dart';
import 'favorite_rate_text.dart';

class FavoritePairRow extends StatelessWidget {
  const FavoritePairRow({
    required this.pair,
    required this.snapshot,
    required this.showDivider,
    required this.onOpen,
    required this.onRemove,
    super.key,
  });

  final FavoritePair pair;
  final LatestRatesSnapshot? snapshot;
  final bool showDivider;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loc = l10n(context);
    final rate = rateForFavoritePair(pair: pair, snapshot: snapshot);
    return Column(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onOpen();
            },
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppTheme.rowMinHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.border.withValues(alpha: .32),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: CurrencyFlagIcon(
                          code: pair.base,
                          symbol: CurrencyFlags.forCode(pair.base),
                          radius: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: FavoritePairIdentity(pair: pair)),
                    const SizedBox(width: 12),
                    FavoriteRateText(rate: rate),
                    const SizedBox(width: 12),
                    Semantics(
                      button: true,
                      label: loc.removeFavoriteTooltip,
                      child: InkWell(
                        onTap: () => HapticFeedback.selectionClick(),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.subtle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: colors.border.withValues(alpha: .20),
            indent: 62,
          ),
      ],
    );
  }
}
