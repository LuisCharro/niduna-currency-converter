import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/divider_list_row.dart';
import '../../shared/widgets/pill_action.dart';
import '../convert/domain/latest_rates_snapshot.dart';
import '../convert/presentation/convert_controller.dart';
import 'data/favorites_store.dart';
import 'domain/favorite_pair.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    required this.favoritesStore,
    required this.controller,
    required this.onNavigateToConvert,
    super.key,
  });

  final FavoritesStore favoritesStore;
  final ConvertController controller;
  final void Function(String base, String quote) onNavigateToConvert;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bg,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: favoritesStore,
          builder: (context, _) {
            final hasFavorites = !favoritesStore.isEmpty;
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  child: _Header(
                    count: favoritesStore.pairs.length,
                    canAdd: !favoritesStore.isFull,
                    onAdd: () => onNavigateToConvert('', ''),
                  ),
                ),
                if (!hasFavorites)
                  Expanded(
                    child: _EmptyState(
                      canAdd: !favoritesStore.isFull,
                      onAdd: () => onNavigateToConvert('', ''),
                    ),
                  )
                else
                  Expanded(
                    child: _FavoritesList(
                      pairs: favoritesStore.pairs,
                      snapshot: controller.snapshot,
                      onTap: (pair) =>
                          onNavigateToConvert(pair.base, pair.quote),
                      onDismissed: (pair) =>
                          favoritesStore.remove(pair.base, pair.quote),
                    ),
                  ),
                if (hasFavorites && favoritesStore.isFull)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: _MaxFavoritesNote(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.canAdd,
    required this.onAdd,
  });

  final int count;
  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Favorites',
                style: AppTheme.heading.copyWith(
                  fontFamily: 'Fraunces',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saved pairs · $count',
                style: AppTheme.caption.copyWith(color: AppTheme.muted),
              ),
            ],
          ),
        ),
        if (canAdd)
          PillAction(label: 'Add', icon: Icons.add_rounded, onTap: onAdd),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.canAdd, required this.onAdd});

  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decoration: BoxDecoration(
            color: AppTheme.container.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.star_outline_rounded, size: 52, color: AppTheme.muted),
              const SizedBox(height: 14),
              Text(
                'No saved pairs yet',
                style: AppTheme.heading.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Star a row in Convert and it will stay here like a pinned instrument.',
                style: AppTheme.body.copyWith(
                  color: AppTheme.muted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (canAdd) ...<Widget>[
                const SizedBox(height: 18),
                PillAction(
                  label: 'Open Convert',
                  icon: Icons.arrow_forward_rounded,
                  onTap: onAdd,
                  emphasized: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({
    required this.pairs,
    required this.snapshot,
    required this.onTap,
    required this.onDismissed,
  });

  final List<FavoritePair> pairs;
  final LatestRatesSnapshot? snapshot;
  final ValueChanged<FavoritePair> onTap;
  final ValueChanged<FavoritePair> onDismissed;

  Map<String, double> get _allRates => snapshot?.rates ?? <String, double>{};
  String get _snapBase => snapshot?.base ?? '';

  double? _rateFor(FavoritePair pair) {
    final rates = _allRates;
    final snapBase = _snapBase;

    if (snapBase == pair.base) return rates[pair.quote];
    if (snapBase == pair.quote) {
      final baseRate = rates[pair.base];
      if (baseRate == null || baseRate == 0) return null;
      return 1.0 / baseRate;
    }

    final baseRate = rates[pair.base];
    final quoteRate = rates[pair.quote];
    if (baseRate == null || quoteRate == null || baseRate == 0) return null;
    return quoteRate / baseRate;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: pairs.length,
      itemBuilder: (context, index) {
        final pair = pairs[index];
        return Dismissible(
          key: Key(pair.toKey()),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDismissed(pair),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.trendDown.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete_outline, color: AppTheme.trendDown),
          ),
          child: _FavoriteRow(
            pair: pair,
            rate: _rateFor(pair),
            showDivider: index != pairs.length - 1,
            onTap: () => onTap(pair),
            onRemove: () => onDismissed(pair),
          ),
        );
      },
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({
    required this.pair,
    required this.rate,
    required this.showDivider,
    required this.onTap,
    required this.onRemove,
  });

  final FavoritePair pair;
  final double? rate;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DividerListRow(
      onTap: onTap,
      showDivider: showDivider,
      leadingAccent: AppTheme.primary.withValues(alpha: .18),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.remove_circle_outline,
              size: 20,
              color: AppTheme.subtle,
            ),
            tooltip: 'Remove ${pair.base}→${pair.quote}',
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.subtle),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${pair.base} → ${pair.quote}',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rate != null ? rate!.toStringAsFixed(4) : '—',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text,
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxFavoritesNote extends StatelessWidget {
  const _MaxFavoritesNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.lock_outline, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Phase 1 keeps favorites capped at 3 pairs.',
            style: AppTheme.caption.copyWith(color: AppTheme.muted),
          ),
        ),
      ],
    );
  }
}
