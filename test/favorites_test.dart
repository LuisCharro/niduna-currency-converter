import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair.dart';
import 'package:currency_converter/src/features/favorites/domain/favorite_pair_rate.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';

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
}

LatestRatesSnapshot _snapshot({
  required String base,
  required Map<String, double> rates,
}) {
  return LatestRatesSnapshot(
    base: base,
    date: DateTime(2026, 5, 8),
    savedAt: DateTime(2026, 5, 8, 9),
    rates: rates,
  );
}
