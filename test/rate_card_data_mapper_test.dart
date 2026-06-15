import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/features/convert/domain/convert_state.dart';
import 'package:currency_converter/src/features/convert/models/currency_quote.dart';
import 'package:currency_converter/src/features/convert/presentation/rate_card_data_mapper.dart';

void main() {
  ConvertState state() => ConvertState(
        status: ConvertStatus.fresh,
        quotes: const <CurrencyQuote>[
          CurrencyQuote('€', 'EUR', 'Euro', '86.34', '1 USD = 0.86 EUR',
              rate: 0.8634),
          CurrencyQuote('£', 'GBP', 'British Pound', '74.57', '1 USD = 0.75 GBP',
              rate: 0.7457),
        ],
        lastUpdatedLabel: 'Updated Jun 15',
        nextUpdateLabel: 'Next around 4pm',
        base: 'USD',
        amountText: '100.00',
        selectedCodes: const <String>['EUR', 'GBP'],
      );

  test('maps base amount, rows, and footer', () {
    final data = rateCardDataFromState(state());

    expect(data.baseAmountLabel, '100 USD');
    expect(data.footerLabel, 'Updated Jun 15');
    expect(data.rows.length, 2);
    expect(data.rows.first.name, 'Euro');
    expect(data.rows.first.valueLabel, '€ 86.34');
  });

  test('keeps two decimals for non-integer amounts', () {
    final data = rateCardDataFromState(
      state().copyWith(amountText: '12.50'),
    );
    expect(data.baseAmountLabel, '12.50 USD');
  });
}
