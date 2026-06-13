import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/widget/widget_data.dart';
import 'package:currency_converter/src/core/widget/home_widget_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetData', () {
    test('constructs with all fields', () {
      const data = HomeWidgetData(
        baseCode: 'GBP',
        amountLabel: '50 GBP',
        updatedLabel: 'updated just now',
        pairs: [
          WidgetPair(
            code: 'JPY',
            symbol: '¥',
            value: '9425.00',
            trend: 'up',
            changePercent: '0.42%',
          ),
        ],
      );

      expect(data.baseCode, 'GBP');
      expect(data.amountLabel, '50 GBP');
      expect(data.updatedLabel, 'updated just now');
      expect(data.pairs.length, 1);
      expect(data.pairs.first.code, 'JPY');
      expect(data.pairs.first.symbol, '¥');
      expect(data.pairs.first.value, '9425.00');
      expect(data.pairs.first.trend, 'up');
      expect(data.pairs.first.changePercent, '0.42%');
    });

    test('uses default values when omitted', () {
      const data = HomeWidgetData();

      expect(data.baseCode, 'USD');
      expect(data.amountLabel, '100 USD');
      expect(data.updatedLabel, '');
      expect(data.pairs, isEmpty);
    });

    test('holds up to 3 pairs', () {
      const data = HomeWidgetData(
        baseCode: 'USD',
        amountLabel: '100 USD',
        updatedLabel: 'now',
        pairs: [
          WidgetPair(code: 'EUR', symbol: '€', value: '92.00'),
          WidgetPair(code: 'GBP', symbol: '£', value: '79.00'),
          WidgetPair(code: 'BTC', symbol: '₿', value: '0.0015'),
        ],
      );

      expect(data.pairs.length, 3);
      expect(data.pairs[0].code, 'EUR');
      expect(data.pairs[1].code, 'GBP');
      expect(data.pairs[2].code, 'BTC');
    });

    test('WidgetPair uses default trend and changePercent', () {
      const pair = WidgetPair(code: 'EUR', symbol: '€', value: '92.00');

      expect(pair.trend, 'none');
      expect(pair.changePercent, '');
    });
  });

  group('HomeWidgetProvider', () {
    test('pushData does not throw on missing plugin', () async {
      final provider = HomeWidgetProvider();
      const data = HomeWidgetData();

      await expectLater(provider.pushData(data), completes);
    });

    test(
      'pushData handles 3 pairs without throwing on missing plugin',
      () async {
        final provider = HomeWidgetProvider();
        const data = HomeWidgetData(
          baseCode: 'USD',
          amountLabel: '100 USD',
          updatedLabel: 'now',
          pairs: [
            WidgetPair(code: 'EUR', symbol: '€', value: '92.00'),
            WidgetPair(code: 'GBP', symbol: '£', value: '79.00'),
            WidgetPair(code: 'BTC', symbol: '₿', value: '0.0015'),
          ],
        );

        await expectLater(provider.pushData(data), completes);
      },
    );

    test('clearData does not throw on missing plugin', () async {
      final provider = HomeWidgetProvider();

      await expectLater(provider.clearData(), completes);
    });
  });
}
