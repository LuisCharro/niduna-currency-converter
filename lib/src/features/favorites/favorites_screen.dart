import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../convert/presentation/convert_controller.dart';
import '../convert/domain/latest_rates_snapshot.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ListenableBuilder(
        listenable: favoritesStore,
        builder: (context, _) {
          if (favoritesStore.isEmpty) {
            return _EmptyState();
          }
          return Column(
            children: <Widget>[
              Expanded(
                child: _FavoritesList(
                  pairs: favoritesStore.pairs,
                  snapshot: controller.snapshot,
                  onTap: (pair) => onNavigateToConvert(pair.base, pair.quote),
                  onDismissed: (pair) =>
                      favoritesStore.remove(pair.base, pair.quote),
                ),
              ),
              if (!favoritesStore.isFull)
                _AddButton(
                  onTap: () => onNavigateToConvert('', ''),
                )
              else
                _MaxFavoritesCard(),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.star_outline, size: 56, color: AppTheme.muted),
            const SizedBox(height: 16),
            Text(
              'No favorite pairs yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Star a currency in Convert to save it here',
              style: TextStyle(fontSize: 14, color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
          ],
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

    if (snapBase == pair.base) {
      return rates[pair.quote];
    }
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
    final computedRates = <int, double?>{};
    for (var i = 0; i < pairs.length; i++) {
      computedRates[i] = _rateFor(pairs[i]);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      itemCount: pairs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pair = pairs[index];
        final rate = computedRates[index];
        return Dismissible(
          key: Key(pair.toKey()),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDismissed(pair),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.trendDown.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Icon(Icons.delete_outline, color: AppTheme.trendDown),
          ),
          child: _FavoriteTile(
            pair: pair,
            rate: rate,
            onTap: () => onTap(pair),
            onDismissed: () => onDismissed(pair),
          ),
        );
      },
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.pair,
    required this.rate,
    required this.onTap,
    this.onDismissed,
  });

  final FavoritePair pair;
  final double? rate;
  final VoidCallback onTap;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.border.withValues(alpha: .5)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${pair.base} \u2192 ${pair.quote}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.muted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rate != null ? rate!.toStringAsFixed(4) : '\u2014',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                        fontFeatures: <FontFeature>[
                          const FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismissed != null)
                IconButton(
                  onPressed: onDismissed,
                  icon: Icon(Icons.remove_circle_outline,
                      size: 22, color: AppTheme.subtle),
                  tooltip: 'Remove ${pair.base}→${pair.quote}',
                  constraints:
                      const BoxConstraints.tightFor(width: 44, height: 44),
                  splashRadius: 20,
                )
              else
                const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppTheme.subtle, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(Icons.add, size: 20, color: AppTheme.primary),
          label: Text(
            'Add favorite',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.primary.withValues(alpha: .4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaxFavoritesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppTheme.primary.withValues(alpha: .15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.lock_outline, size: 18, color: AppTheme.primary),
            const SizedBox(width: 10),
            Text(
              'Unlock more favorites',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
