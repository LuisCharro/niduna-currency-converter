import 'package:currency_converter/src/core/currency/currency_code_migration.dart';
import 'package:currency_converter/src/core/monetization/models/temporary_unlock.dart';
import 'package:currency_converter/src/core/monetization/temporary_unlock_store.dart';
import 'package:currency_converter/src/core/preferences/app_preferences.dart';
import 'package:currency_converter/src/features/favorites/data/favorites_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('canonicalCurrencyCode', () {
    test('MATIC maps to POL', () {
      expect(canonicalCurrencyCode('MATIC'), 'POL');
    });

    test('matic lowercase maps to POL', () {
      expect(canonicalCurrencyCode('matic'), 'POL');
    });

    test('whitespace + mixed case maps to POL', () {
      expect(canonicalCurrencyCode('  Matic  '), 'POL');
    });

    test('POL is idempotent', () {
      expect(canonicalCurrencyCode('POL'), 'POL');
    });

    test('other fiat codes pass through (normalized to upper)', () {
      expect(canonicalCurrencyCode('USD'), 'USD');
      expect(canonicalCurrencyCode('eur'), 'EUR');
      expect(canonicalCurrencyCode('gbp'), 'GBP');
    });

    test('other crypto codes pass through', () {
      expect(canonicalCurrencyCode('BTC'), 'BTC');
      expect(canonicalCurrencyCode('sol'), 'SOL');
    });

    test('empty string stays empty', () {
      expect(canonicalCurrencyCode(''), '');
    });

    test('whitespace-only stays empty', () {
      expect(canonicalCurrencyCode('   '), '');
    });
  });

  group('canonicalizeCodeList', () {
    test('MATIC replaced by POL', () {
      expect(
        canonicalizeCodeList(<String>['EUR', 'MATIC', 'BTC']),
        <String>['EUR', 'POL', 'BTC'],
      );
    });

    test('MATIC + POL duplicate collapses to single POL', () {
      expect(
        canonicalizeCodeList(<String>['EUR', 'MATIC', 'POL', 'BTC']),
        <String>['EUR', 'POL', 'BTC'],
      );
    });

    test('preserves order of non-MATIC codes', () {
      expect(
        canonicalizeCodeList(<String>['JPY', 'MATIC', 'CHF']),
        <String>['JPY', 'POL', 'CHF'],
      );
    });

    test('idempotent — running twice yields same result', () {
      final first = canonicalizeCodeList(<String>['EUR', 'MATIC', 'POL']);
      final second = canonicalizeCodeList(first);
      expect(second, equals(first));
    });

    test('empty list stays empty', () {
      expect(canonicalizeCodeList(<String>[]), isEmpty);
    });

    test('unsupported codes preserved (validation is separate layer)', () {
      expect(
        canonicalizeCodeList(<String>['EUR', 'XXX', 'BTC']),
        <String>['EUR', 'XXX', 'BTC'],
      );
    });
  });

  group('canonicalizeFavoriteKey', () {
    test('MATIC-USD → POL-USD', () {
      expect(canonicalizeFavoriteKey('MATIC-USD'), 'POL-USD');
    });

    test('USD-MATIC → USD-POL', () {
      expect(canonicalizeFavoriteKey('USD-MATIC'), 'USD-POL');
    });

    test('lowercase is normalized', () {
      expect(canonicalizeFavoriteKey('matic-usd'), 'POL-USD');
    });

    test('non-MATIC pair unchanged', () {
      expect(canonicalizeFavoriteKey('EUR-USD'), 'EUR-USD');
      expect(canonicalizeFavoriteKey('BTC-USD'), 'BTC-USD');
    });

    test('MATIC-MATIC pair → null (same currency pair is degenerate)', () {
      expect(canonicalizeFavoriteKey('MATIC-MATIC'), isNull);
      expect(canonicalizeFavoriteKey('POL-POL'), isNull);
    });

    test('invalid format returned unchanged (validation is separate layer)',
        () {
      expect(canonicalizeFavoriteKey('INVALID'), 'INVALID');
      expect(canonicalizeFavoriteKey('A-B-C'), 'A-B-C');
    });
  });

  group('canonicalizeFavoriteKeys (list dedup)', () {
    test('MATIC-USD and POL-USD collapse to one POL-USD', () {
      expect(
        canonicalizeFavoriteKeys(<String>['MATIC-USD', 'POL-USD']),
        <String>['POL-USD'],
      );
    });

    test('MATIC-USD + EUR-USD → POL-USD + EUR-USD (order preserved)', () {
      expect(
        canonicalizeFavoriteKeys(<String>['MATIC-USD', 'EUR-USD']),
        <String>['POL-USD', 'EUR-USD'],
      );
    });

    test('drops MATIC-MATIC degenerate pair', () {
      expect(
        canonicalizeFavoriteKeys(<String>['MATIC-MATIC', 'EUR-USD']),
        <String>['EUR-USD'],
      );
    });
  });

  group('AppPreferences MATIC migration', () {
    test('selectedCodes getter canonicalizes legacy MATIC to POL', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'pref_selected_codes': <String>['EUR', 'MATIC', 'BTC'],
      });
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      expect(preferences.selectedCodes, <String>['EUR', 'POL', 'BTC']);
    });

    test('defaultBaseCurrency getter canonicalizes legacy MATIC', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'pref_default_base': 'MATIC',
      });
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      expect(preferences.defaultBaseCurrency, 'POL');
    });

    test('setSelectedCodes canonicalizes before persisting', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      await preferences
          .setSelectedCodes(<String>['EUR', 'MATIC', 'BTC']);

      expect(
        prefs.getStringList('pref_selected_codes'),
        <String>['EUR', 'POL', 'BTC'],
      );
    });

    test('setDefaultBaseCurrency canonicalizes before persisting', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      await preferences.setDefaultBaseCurrency('MATIC');

      expect(prefs.getString('pref_default_base'), 'POL');
    });

    test('setSelectedCodes persists normalized state — second read returns POL',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final preferences = AppPreferences(prefs);

      await preferences.setSelectedCodes(<String>['MATIC']);
      final after = preferences.selectedCodes;
      expect(after, <String>['POL']);
      expect(prefs.getStringList('pref_selected_codes'), <String>['POL']);
    });
  });

  group('FavoritesStore MATIC migration', () {
    test('load canonicalizes MATIC-USD to POL-USD', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'favorite_pairs': <String>['MATIC-USD', 'EUR-USD'],
      });
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);

      expect(
        store.pairs.map((p) => p.toKey()).toList(),
        <String>['POL-USD', 'EUR-USD'],
      );
      store.dispose();
    });

    test('load deduplicates MATIC-USD and POL-USD', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'favorite_pairs': <String>['MATIC-USD', 'POL-USD'],
      });
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);

      expect(store.pairs.length, 1);
      expect(store.pairs.first.toKey(), 'POL-USD');
      store.dispose();
    });

    test('load drops MATIC-MATIC degenerate pair', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'favorite_pairs': <String>['MATIC-MATIC'],
      });
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);

      expect(store.pairs, isEmpty);
      store.dispose();
    });

    test('load preserves non-MATIC pairs unchanged', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'favorite_pairs': <String>['USD-EUR', 'USD-GBP'],
      });
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);

      expect(
        store.pairs.map((p) => p.toKey()).toList(),
        <String>['USD-EUR', 'USD-GBP'],
      );
      store.dispose();
    });

    test('load migration is idempotent — second load yields same result',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'favorite_pairs': <String>['MATIC-USD'],
      });
      final prefs = await SharedPreferences.getInstance();
      final store1 = FavoritesStore(prefs);
      expect(store1.pairs.first.toKey(), 'POL-USD');
      store1.dispose();

      final store2 = FavoritesStore(prefs);
      expect(store2.pairs.first.toKey(), 'POL-USD');
      store2.dispose();
    });
  });

  group('TemporaryUnlockStore MATIC migration', () {
    test('migrateIfNeeded removes MATIC unlock registry entries (legacy format is unsafe to decode)', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final store = TemporaryUnlockStore(prefs);

      await store.save(TemporaryUnlock(
        base: 'MATIC',
        quote: 'USD',
        grantedAt: DateTime(2026, 9, 12, 12),
      ));

      expect(prefs.getString('temp_unlocks_registry'), contains('MATIC'));

      await store.migrateIfNeeded();

      final after = prefs.getString('temp_unlocks_registry');
      expect(after, isNotNull);
      // Legacy format cannot be safely decoded; per plan §C4, MATIC entries
      // are removed (not migrated to POL). The registry collapses to {}.
      expect(after, equals('{}'));
    });

    test('migrateIfNeeded is idempotent', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final store = TemporaryUnlockStore(prefs);

      await store.save(TemporaryUnlock(
        base: 'MATIC',
        quote: 'USD',
        grantedAt: DateTime(2026, 9, 12, 12),
      ));

      await store.migrateIfNeeded();
      final firstRaw = prefs.getString('temp_unlocks_registry');

      await store.migrateIfNeeded();
      final secondRaw = prefs.getString('temp_unlocks_registry');

      expect(secondRaw, equals(firstRaw));
    });

    test('migrateIfNeeded then fresh save works (registry can grow again)',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final store = TemporaryUnlockStore(prefs);

      await store.save(TemporaryUnlock(
        base: 'MATIC',
        quote: 'USD',
        grantedAt: DateTime(2026, 9, 12, 12),
      ));
      await store.migrateIfNeeded();

      // Add a fresh unlock after migration — should not crash and should
      // appear in the registry.
      await store.save(TemporaryUnlock(
        base: 'USD',
        quote: 'EUR',
        grantedAt: DateTime(2026, 9, 12, 13),
      ));

      final raw = prefs.getString('temp_unlocks_registry');
      expect(raw, isNotNull);
      // TemporaryUnlock.canonicalKey sorts alphabetically — USD/EUR is stored as EUR_USD.
      expect(raw!, contains('EUR_USD'));
      expect(raw, isNot(contains('MATIC')));
    });

    test('migrateIfNeeded preserves non-MATIC unlocks byte-equivalent',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final store = TemporaryUnlockStore(prefs);

      // A MATIC unlock and a BTC unlock together
      await store.save(TemporaryUnlock(
        base: 'MATIC',
        quote: 'USD',
        grantedAt: DateTime(2026, 9, 12, 12),
      ));
      await store.save(TemporaryUnlock(
        base: 'BTC',
        quote: 'EUR',
        grantedAt: DateTime(2026, 9, 12, 12),
      ));

      final before = prefs.getString('temp_unlocks_registry');
      expect(before, contains('BTC_EUR'));

      await store.migrateIfNeeded();

      final after = prefs.getString('temp_unlocks_registry');
      // BTC entry survives the MATIC removal byte-equivalent.
      expect(after, contains('BTC_EUR'));
      expect(after, isNot(contains('MATIC')));
    });
  });
}
