import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair_rate.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/models/trend.dart';
import 'package:currency_converter/src/features/convert/models/trend_direction.dart';

void main() {
  group('FavoritePair', () {
    test('toKey returns base-quote', () {
      const pair = FavoritePair(base: 'USD', quote: 'EUR');
      expect(pair.toKey(), 'USD-EUR');
    });

    test('fromKey parses correctly', () {
      final pair = FavoritePair.fromKey('GBP-JPY');
      expect(pair.base, 'GBP');
      expect(pair.quote, 'JPY');
    });

    test('fromKey throws on invalid format', () {
      expect(() => FavoritePair.fromKey('USD'), throwsFormatException);
    });

    test('equality works', () {
      const a = FavoritePair(base: 'USD', quote: 'EUR');
      const b = FavoritePair(base: 'USD', quote: 'EUR');
      expect(a, equals(b));
    });

    test('inequality works', () {
      const a = FavoritePair(base: 'USD', quote: 'EUR');
      const b = FavoritePair(base: 'USD', quote: 'GBP');
      expect(a, isNot(equals(b)));
    });

    test('toString formats arrow', () {
      const pair = FavoritePair(base: 'USD', quote: 'EUR');
      expect(pair.toString(), 'USD → EUR');
    });
  });

  group('FavoritesStore', () {
    late SharedPreferences prefs;
    late FavoritesStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      store = FavoritesStore(prefs);
    });

    tearDown(() {
      store.dispose();
    });

    test('starts empty', () {
      expect(store.isEmpty, isTrue);
      expect(store.pairs, isEmpty);
    });

    test('add pair', () async {
      await store.add('USD', 'EUR');
      expect(store.pairs.length, 1);
      expect(store.isFavorite('USD', 'EUR'), isTrue);
    });

    test('add duplicate ignored', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'EUR');
      expect(store.pairs.length, 1);
    });

    test('store does not enforce a hard cap', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');
      await store.add('USD', 'CHF');
      expect(store.pairs.length, 4);
    });

    test('canAdd with limit parameter', () {
      expect(store.canAdd('USD', 'EUR', 3), isTrue);
    });

    test('canAdd with limit returns true when already favorite', () async {
      await store.add('USD', 'EUR');
      expect(store.canAdd('USD', 'EUR', 1), isTrue);
    });

    test('canAdd with limit returns false when at limit and not favorite',
        () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');
      expect(store.canAdd('USD', 'CHF', 3), isFalse);
    });

    test('remove pair', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.remove('USD', 'EUR');
      expect(store.pairs.length, 1);
      expect(store.isFavorite('USD', 'EUR'), isFalse);
      expect(store.isFavorite('USD', 'GBP'), isTrue);
    });

    test('toggle adds and removes', () async {
      await store.toggle('USD', 'EUR');
      expect(store.isFavorite('USD', 'EUR'), isTrue);
      await store.toggle('USD', 'EUR');
      expect(store.isFavorite('USD', 'EUR'), isFalse);
    });

    test('canAdd returns true when not full', () {
      expect(store.canAdd('USD', 'EUR', 3), isTrue);
    });

    test('canAdd returns true when already favorite', () async {
      await store.add('USD', 'EUR');
      expect(store.canAdd('USD', 'EUR', 3), isTrue);
    });

    test('canAdd returns false when full and not favorite', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');
      expect(store.canAdd('USD', 'CHF', 3), isFalse);
    });

    test('isFavorite returns false for different base', () async {
      await store.add('USD', 'EUR');
      expect(store.isFavorite('GBP', 'EUR'), isFalse);
    });

    test('persistence survives store recreation', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      store.dispose();

      final store2 = FavoritesStore(prefs);
      expect(store2.pairs.length, 2);
      expect(store2.isFavorite('USD', 'EUR'), isTrue);
      expect(store2.isFavorite('USD', 'GBP'), isTrue);
      store2.dispose();

      // Prevent tearDown from double-disposing
      store = FavoritesStore(prefs);
    });

    test('invalid stored keys are skipped on load', () async {
      await prefs.setStringList('favorite_pairs', ['USD-EUR', 'INVALID']);
      store.dispose();

      final store2 = FavoritesStore(prefs);
      expect(store2.pairs.length, 1);
      expect(store2.isFavorite('USD', 'EUR'), isTrue);
      store2.dispose();

      store = FavoritesStore(prefs);
    });
  });

  group('reorder (manual order)', () {
    late SharedPreferences prefs;
    late FavoritesStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      store = FavoritesStore(prefs);
    });

    tearDown(() => store.dispose());

    test('moves an item from first to last', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');

      await store.reorder(0, 3); // ReorderableListView passes end+1

      expect(store.pairs.map((p) => p.quote).toList(),
          <String>['GBP', 'JPY', 'EUR']);
    });

    test('moves an item from last to first', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');

      await store.reorder(2, 0);

      expect(store.pairs.map((p) => p.quote).toList(),
          <String>['JPY', 'EUR', 'GBP']);
    });

    test('persists the new order across a reload', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.reorder(1, 0);

      final reloaded = FavoritesStore(prefs);
      expect(reloaded.pairs.map((p) => p.quote).toList(),
          <String>['GBP', 'EUR']);
      reloaded.dispose();
    });

    test('out-of-range oldIndex is a no-op', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');

      await store.reorder(5, 0);

      expect(store.pairs.map((p) => p.quote).toList(),
          <String>['EUR', 'GBP']);
    });
  });

  group('sortedPairs (auto-sort by usage)', () {
    late SharedPreferences prefs;
    late FavoritesStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      store = FavoritesStore(prefs);
    });

    tearDown(() => store.dispose());

    test('orders by use count, most-used first', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.add('USD', 'JPY');
      await store.recordUsage('USD', 'GBP');
      await store.recordUsage('USD', 'GBP');
      await store.recordUsage('USD', 'JPY');

      final order = store.sortedPairs.map((p) => p.quote).toList();
      expect(order, <String>['GBP', 'JPY', 'EUR']);
    });

    test('annotates useCount on the returned pairs', () async {
      await store.add('USD', 'EUR');
      await store.recordUsage('USD', 'EUR');
      await store.recordUsage('USD', 'EUR');

      expect(store.sortedPairs.single.useCount, 2);
    });

    test('breaks ties by most recently used', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.recordUsage('USD', 'EUR');
      await store.recordUsage('USD', 'GBP'); // same count, used later

      final order = store.sortedPairs.map((p) => p.quote).toList();
      expect(order, <String>['GBP', 'EUR']);
    });

    test('does not mutate insertion order of pairs getter', () async {
      await store.add('USD', 'EUR');
      await store.add('USD', 'GBP');
      await store.recordUsage('USD', 'GBP');

      expect(store.pairs.map((p) => p.quote).toList(),
          <String>['EUR', 'GBP']); // pairs stays insertion order
      expect(store.sortedPairs.map((p) => p.quote).toList(),
          <String>['GBP', 'EUR']); // sortedPairs reflects usage
    });
  });

  group('rateForFavoritePair', () {
    test('returns direct rate from snapshot base', () {
      final rate = rateForFavoritePair(
        pair: const FavoritePair(base: 'USD', quote: 'EUR'),
        snapshot: _snapshot(
          base: 'USD',
          rates: const <String, double>{'EUR': .92},
        ),
      );

      expect(rate, .92);
    });

    test('returns inverse rate from snapshot quote', () {
      final rate = rateForFavoritePair(
        pair: const FavoritePair(base: 'EUR', quote: 'USD'),
        snapshot: _snapshot(
          base: 'USD',
          rates: const <String, double>{'EUR': .8},
        ),
      );

      expect(rate, 1.25);
    });

    test('returns cross rate from third snapshot base', () {
      final rate = rateForFavoritePair(
        pair: const FavoritePair(base: 'EUR', quote: 'GBP'),
        snapshot: _snapshot(
          base: 'USD',
          rates: const <String, double>{'EUR': .8, 'GBP': .7},
        ),
      );

      expect(rate, closeTo(.875, 0.000000001));
    });

    test('returns null when a rate is missing', () {
      final rate = rateForFavoritePair(
        pair: const FavoritePair(base: 'EUR', quote: 'GBP'),
        snapshot: _snapshot(
          base: 'USD',
          rates: const <String, double>{'EUR': .8},
        ),
      );

      expect(rate, isNull);
    });

    test('returns null for zero denominator', () {
      final rate = rateForFavoritePair(
        pair: const FavoritePair(base: 'EUR', quote: 'GBP'),
        snapshot: _snapshot(
          base: 'USD',
          rates: const <String, double>{'EUR': 0, 'GBP': .7},
        ),
      );

      expect(rate, isNull);
    });
  });

  group('previousRateForFavoritePair + trend', () {
    test('reads the previous rate with the same cross-rate math', () {
      final prev = previousRateForFavoritePair(
        pair: const FavoritePair(base: 'EUR', quote: 'USD'),
        snapshot: _snapshot(
          base: 'USD',
          rates: const <String, double>{'EUR': .8},
          previousRates: const <String, double>{'EUR': .8},
        ),
      );
      // inverse of 0.8 == 1.25
      expect(prev, 1.25);
    });

    test('returns null when no previous rates present', () {
      final prev = previousRateForFavoritePair(
        pair: const FavoritePair(base: 'USD', quote: 'EUR'),
        snapshot: _snapshot(
          base: 'USD',
          rates: const <String, double>{'EUR': .92},
        ),
      );
      expect(prev, isNull);
    });

    test('shows an up trend when the rate rose', () {
      const pair = FavoritePair(base: 'USD', quote: 'EUR');
      final snapshot = _snapshot(
        base: 'USD',
        rates: const <String, double>{'EUR': .92},
        previousRates: const <String, double>{'EUR': .90},
      );
      final rate = rateForFavoritePair(pair: pair, snapshot: snapshot);
      final prev = previousRateForFavoritePair(pair: pair, snapshot: snapshot);
      final trend = trendDirectionFor(rate, prev);

      expect(trend, TrendDirection.up);
      expect(shouldShowTrend(trend, changePercentFor(rate, prev)), isTrue);
    });

    test('hides the trend when the change rounds to 0.00%', () {
      const pair = FavoritePair(base: 'USD', quote: 'EUR');
      final snapshot = _snapshot(
        base: 'USD',
        rates: const <String, double>{'EUR': .920001},
        previousRates: const <String, double>{'EUR': .920000},
      );
      final rate = rateForFavoritePair(pair: pair, snapshot: snapshot);
      final prev = previousRateForFavoritePair(pair: pair, snapshot: snapshot);

      expect(
        shouldShowTrend(trendDirectionFor(rate, prev),
            changePercentFor(rate, prev)),
        isFalse,
      );
    });
  });
}

LatestRatesSnapshot _snapshot({
  required String base,
  required Map<String, double> rates,
  Map<String, double>? previousRates,
}) {
  return LatestRatesSnapshot(
    base: base,
    date: DateTime(2026, 5, 8),
    savedAt: DateTime(2026, 5, 8, 9),
    rates: rates,
    previousRates: previousRates,
  );
}
