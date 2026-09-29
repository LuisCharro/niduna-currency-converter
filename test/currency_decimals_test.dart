import 'package:currency_converter/src/core/currency/currency_decimals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isZeroDecimalCurrency', () {
    test('is true for JPY, KRW and CLP', () {
      expect(isZeroDecimalCurrency('JPY'), isTrue);
      expect(isZeroDecimalCurrency('KRW'), isTrue);
      expect(isZeroDecimalCurrency('CLP'), isTrue);
    });

    test('is false for regular 2-decimal currencies', () {
      expect(isZeroDecimalCurrency('USD'), isFalse);
      expect(isZeroDecimalCurrency('EUR'), isFalse);
      expect(isZeroDecimalCurrency('GBP'), isFalse);
    });

    test('HUF is intentionally left as a 2-decimal currency', () {
      expect(isZeroDecimalCurrency('HUF'), isFalse);
    });
  });

  group('decimalsForCurrency', () {
    test('zero-decimal currencies always resolve to 0 regardless of default', () {
      expect(decimalsForCurrency('JPY', 2), 0);
      expect(decimalsForCurrency('JPY', 4), 0);
      expect(decimalsForCurrency('KRW', 6), 0);
      expect(decimalsForCurrency('CLP', 0), 0);
    });

    test('other currencies keep the requested default decimal places', () {
      expect(decimalsForCurrency('USD', 2), 2);
      expect(decimalsForCurrency('EUR', 4), 4);
      expect(decimalsForCurrency('HUF', 2), 2);
    });
  });
}
