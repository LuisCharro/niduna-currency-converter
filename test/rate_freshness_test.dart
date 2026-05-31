import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:currency_converter/src/features/convert/domain/rate_freshness.dart';

void main() {
  setUp(() async {
    Intl.defaultLocale = 'en';
    await initializeDateFormatting('en', null);
  });

  test('updatedLabel with rateDate shows formatted date', () {
    final rateDate = DateTime(2026, 5, 30);
    final savedAt = DateTime(2026, 5, 31, 10, 0);

    final label = RateFreshness.updatedLabel(
      rateDate: rateDate,
      savedAt: savedAt,
    );

    expect(label, contains('Updated'));
    expect(label, contains('May'));
    expect(label, contains('30'));
  });

  test('updatedLabel with null rateDate shows savedAt timestamp', () {
    final savedAt = DateTime(2026, 5, 31, 14, 30);

    final label = RateFreshness.updatedLabel(
      rateDate: null,
      savedAt: savedAt,
    );

    expect(label, contains('Updated'));
    expect(label, contains('May'));
    expect(label, contains('31'));
  });

  test('nextExpectedUpdate returns a future DateTime', () {
    final now = DateTime(2026, 5, 27, 8, 0);
    final next = RateFreshness.nextExpectedUpdate(now: now);

    expect(next.isAfter(now), isTrue);
  });

  test('nextExpectedUpdate skips weekends', () {
    final fridayAfterUpdate = DateTime(2026, 5, 29, 16, 0);
    final next = RateFreshness.nextExpectedUpdate(
      now: fridayAfterUpdate,
    );

    expect(next.weekday, isNot(DateTime.saturday));
    expect(next.weekday, isNot(DateTime.sunday));
  });

  test('locale-specific labels contain expected text for en', () {
    Intl.defaultLocale = 'en';
    final label = RateFreshness.updatedLabel(
      rateDate: DateTime(2026, 5, 30),
      savedAt: DateTime(2026, 5, 31),
    );

    expect(label, startsWith('Updated'));
  });

  test('locale-specific labels contain expected text for es', () {
    Intl.defaultLocale = 'es';
    final label = RateFreshness.updatedLabel(
      rateDate: DateTime(2026, 5, 30),
      savedAt: DateTime(2026, 5, 31),
    );

    expect(label, startsWith('Actualizado'));
  });
}
