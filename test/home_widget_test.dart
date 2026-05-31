import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/widget/widget_data.dart';
import 'package:currency_converter/src/core/widget/home_widget_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetData', () {
    test('serializes to JSON and back', () {
      const original = HomeWidgetData(
        baseCode: 'GBP',
        quoteCode: 'JPY',
        rate: 188.5,
        amount: 50.0,
        convertedAmount: '9425.00',
        updatedAt: '2026-05-31T12:00:00Z',
      );

      final json = original.toJson();
      final roundTripped = HomeWidgetData.fromJson(json);

      expect(roundTripped.baseCode, original.baseCode);
      expect(roundTripped.quoteCode, original.quoteCode);
      expect(roundTripped.rate, original.rate);
      expect(roundTripped.amount, original.amount);
      expect(roundTripped.convertedAmount, original.convertedAmount);
      expect(roundTripped.updatedAt, original.updatedAt);
    });

    test('all fields present after round-trip', () {
      final json = <String, dynamic>{
        'baseCode': 'USD',
        'quoteCode': 'EUR',
        'rate': 0.92,
        'amount': 100.0,
        'convertedAmount': '92.00',
        'updatedAt': '2026-05-30',
      };

      final data = HomeWidgetData.fromJson(json);
      final outputJson = data.toJson();

      expect(outputJson.length, 6);
      expect(outputJson['baseCode'], 'USD');
      expect(outputJson['quoteCode'], 'EUR');
      expect(outputJson['rate'], 0.92);
      expect(outputJson['amount'], 100.0);
      expect(outputJson['convertedAmount'], '92.00');
      expect(outputJson['updatedAt'], '2026-05-30');
    });

    test('fromJson uses defaults for missing fields', () {
      final data = HomeWidgetData.fromJson({});

      expect(data.baseCode, 'USD');
      expect(data.quoteCode, 'EUR');
      expect(data.rate, 0.0);
      expect(data.amount, 100.0);
      expect(data.convertedAmount, '');
      expect(data.updatedAt, '');
    });
  });

  group('HomeWidgetProvider', () {
    test('pushData does not throw on missing plugin', () async {
      final provider = HomeWidgetProvider();
      const data = HomeWidgetData();

      await expectLater(provider.pushData(data), completes);
    });

    test('clearData does not throw on missing plugin', () async {
      final provider = HomeWidgetProvider();

      await expectLater(provider.clearData(), completes);
    });
  });
}
