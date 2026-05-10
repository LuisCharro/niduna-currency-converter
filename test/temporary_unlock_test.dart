import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/monetization/models/temporary_unlock.dart';

void main() {
  group('TemporaryUnlock', () {
    test('canonicalKey produces stable sorted key', () {
      expect(TemporaryUnlock.canonicalKey('USD', 'EUR'), 'EUR_USD');
      expect(TemporaryUnlock.canonicalKey('EUR', 'USD'), 'EUR_USD');
      expect(TemporaryUnlock.canonicalKey('GBP', 'JPY'), 'GBP_JPY');
    });

    test('fromJson/toJson round-trip preserves all fields', () {
      final original = TemporaryUnlock(
        base: 'USD',
        quote: 'GBP',
        grantedAt: DateTime(2026, 5, 10, 12, 0, 0),
        duration: const Duration(hours: 24),
      );

      final json = original.toJson();
      final restored = TemporaryUnlock.fromJson(json);

      expect(restored.base, original.base);
      expect(restored.quote, original.quote);
      expect(restored.grantedAt, original.grantedAt);
      expect(restored.duration, original.duration);
    });

    test('fresh unlock is not expired', () {
      final unlock = TemporaryUnlock(
        base: 'USD',
        quote: 'GBP',
        grantedAt: DateTime.now(),
      );
      expect(unlock.isExpired, isFalse);
    });

    test('unlock expired after 24h', () {
      final unlock = TemporaryUnlock(
        base: 'USD',
        quote: 'GBP',
        grantedAt: DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(unlock.isExpired, isTrue);
    });

    test('unlock not expired just under 24h', () {
      final unlock = TemporaryUnlock(
        base: 'USD',
        quote: 'GBP',
        grantedAt:
            DateTime.now().subtract(const Duration(hours: 23, minutes: 59)),
      );
      expect(unlock.isExpired, isFalse);
    });

    test('storageKey uses canonical key', () {
      final unlock = TemporaryUnlock(
        base: 'USD',
        quote: 'GBP',
        grantedAt: DateTime(2026, 5, 10),
      );
      expect(unlock.storageKey, 'temp_unlock_GBP_USD');
    });
  });
}
