import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:currency_converter/src/features/convert/domain/rate_freshness.dart';

void main() {
  setUp(() async {
    Intl.defaultLocale = 'en';
    await initializeDateFormatting('en', null);
  });

  test('updatedLabel identifies the provider rate date', () {
    final rateDate = DateTime(2026, 5, 30);
    final savedAt = DateTime(2026, 5, 31, 10, 0);

    final label = RateFreshness.updatedLabel(
      rateDate: rateDate,
      savedAt: savedAt,
    );

    expect(label, 'Rates from May 30');
  });

  test('updatedLabel with null rateDate shows savedAt timestamp', () {
    final savedAt = DateTime(2026, 5, 31, 14, 30);

    final label = RateFreshness.updatedLabel(rateDate: null, savedAt: savedAt);

    expect(label, contains('Updated'));
    expect(label, contains('May'));
    expect(label, contains('31'));
  });

  test('nextUpdateLabel describes the app policy without a fixed time', () {
    final label = RateFreshness.nextUpdateLabel();

    expect(
      label,
      'Checks automatically the first time you open the app each day',
    );
    expect(label, isNot(contains('4:00')));
  });

  test('locale-specific labels contain expected text for en', () {
    Intl.defaultLocale = 'en';
    final label = RateFreshness.updatedLabel(
      rateDate: DateTime(2026, 5, 30),
      savedAt: DateTime(2026, 5, 31),
    );

    expect(label, startsWith('Rates from'));
  });

  test('locale-specific labels contain expected text for es', () {
    Intl.defaultLocale = 'es';
    final label = RateFreshness.updatedLabel(
      rateDate: DateTime(2026, 5, 30),
      savedAt: DateTime(2026, 5, 31),
    );

    expect(label, startsWith('Tipos del'));
  });
}
