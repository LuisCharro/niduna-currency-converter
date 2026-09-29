import 'package:currency_converter/src/core/currency/amount_formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatConvertedAmount', () {
    test('fiat currencies use the requested decimal places', () {
      expect(formatConvertedAmount(1234.5, 'USD', 2), '1,234.50');
      expect(formatConvertedAmount(1234.5, 'EUR', 4), '1,234.5000');
    });

    test('zero-decimal currencies never show a fractional part', () {
      expect(formatConvertedAmount(15733.49, 'JPY', 2), '15,733');
      expect(formatConvertedAmount(15733.5, 'JPY', 4), '15,734');
      expect(formatConvertedAmount(1000, 'KRW', 2), '1,000');
      expect(formatConvertedAmount(500, 'CLP', 2), '500');
    });

    test('crypto currencies use their fixed asset precision, not decimalPlaces', () {
      expect(formatConvertedAmount(0.1, 'BTC', 2), '0.10000000');
      expect(formatConvertedAmount(10, 'USDT', 2), '10.00');
      expect(formatConvertedAmount(10, 'DOGE', 2), '10.0000');
    });
  });

  test('cryptoAmountDigits matches the app-wide crypto precision table', () {
    expect(cryptoAmountDigits('BTC'), 8);
    expect(cryptoAmountDigits('USDT'), 2);
    expect(cryptoAmountDigits('USDC'), 2);
    expect(cryptoAmountDigits('DOGE'), 4);
    expect(cryptoAmountDigits('ETH'), 6);
  });
}
