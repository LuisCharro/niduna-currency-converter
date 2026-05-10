import 'package:currency_converter/src/core/currency/supported_currencies.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/data/frankfurter_latest_rates_client.dart';
import 'package:currency_converter/src/features/convert/domain/convert_quote_builder.dart';
import 'package:currency_converter/src/features/convert/domain/convert_state.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('supported currencies match Phase 1 fiat scope', () {
    final codes = supportedCurrencies.map((currency) => currency.code).toSet();

    expect(codes, hasLength(16));
    expect(
      codes,
      containsAll(<String>[
        'USD',
        'EUR',
        'GBP',
        'JPY',
        'CAD',
        'AUD',
        'CNY',
        'INR',
        'MXN',
        'BRL',
        'TRY',
        'KRW',
        'SGD',
        'HKD',
        'NZD',
        'CHF',
      ]),
    );
    expect(codes, isNot(contains(anyOf('RUB', 'BTC', 'ETH', 'XAU', 'XAG'))));
  });

  test('buildQuotes calculates amount locally and excludes base', () {
    final quotes = buildQuotes(
      amount: 100,
      decimalPlaces: 2,
      quoteCodes: ['CHF', 'EUR'],
      snapshot: _snapshot(<String, double>{'EUR': .9234, 'CHF': .88}),
    );

    final codes = quotes.map((q) => q.code).toSet();
    expect(codes, {'CHF', 'EUR'});
    final eurQuote = quotes.firstWhere((q) => q.code == 'EUR');
    expect(eurQuote.amount, '92.34');
    expect(eurQuote.rateLine, '1 USD = 0.92 EUR');
  });

  test('controller returns fresh data on successful fetch', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(
        fresh: _snapshot(<String, double>{'EUR': .92}),
      ),
    );

    await controller.load();

    expect(controller.state.status, ConvertStatus.fresh);
    expect(controller.state.quotes.single.code, 'EUR');
  });

  test('controller recalculates visible quotes when amount changes', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(
        fresh: _snapshot(<String, double>{'EUR': .92}),
      ),
      selectedCodes: <String>['EUR'],
    );

    await controller.load();
    controller.setAmountText('200');

    expect(controller.state.amountText, '200');
    expect(controller.state.quotes.single.amount, '184.00');
  });

  test('controller can add and remove visible currencies', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(
        fresh: _snapshot(<String, double>{'EUR': .92, 'NZD': 1.64}),
      ),
      selectedCodes: <String>['EUR'],
    );

    await controller.load();
    controller.toggleCode('NZD');
    expect(controller.state.quotes.map((quote) => quote.code), <String>[
      'EUR',
      'NZD',
    ]);

    controller.toggleCode('EUR');
    expect(controller.state.quotes.single.code, 'NZD');
  });

  test('controller falls back to cached data on network failure', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(
        cached: _snapshot(<String, double>{'EUR': .91}),
        shouldFail: true,
      ),
    );

    await controller.load();

    expect(controller.state.status, ConvertStatus.stale);
    expect(controller.state.quotes.single.amount, '91.00');
    expect(controller.state.message, contains('cached'));
  });

  test('controller reports no cache when first fetch fails', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(shouldFail: true),
    );

    await controller.load();

    expect(controller.state.status, ConvertStatus.noCache);
    expect(controller.state.quotes, isEmpty);
  });

  test('Frankfurter client parses v2 rates list payload', () async {
    final client = FrankfurterLatestRatesClient(
      client: MockClient((request) async {
        expect(request.url.path, '/v2/rates');
        expect(request.url.queryParameters['base'], 'USD');
        expect(request.url.queryParameters['quotes'], contains('EUR'));
        return http.Response(
          '[{"date":"2026-05-08","base":"USD","quote":"EUR","rate":0.85025}]',
          200,
        );
      }),
    );

    final snapshot = await client.fetchLatest('USD');

    expect(snapshot.base, 'USD');
    expect(snapshot.date, DateTime(2026, 5, 8));
    expect(snapshot.rates['EUR'], .85025);
  });
}

LatestRatesSnapshot _snapshot(Map<String, double> rates) {
  return LatestRatesSnapshot(
    base: 'USD',
    date: DateTime(2026, 5, 8),
    savedAt: DateTime(2026, 5, 8, 9),
    rates: rates,
  );
}

class _FakeRatesRepository implements ConvertRatesRepository {
  _FakeRatesRepository({this.cached, this.fresh, this.shouldFail = false});

  final LatestRatesSnapshot? cached;
  final LatestRatesSnapshot? fresh;
  final bool shouldFail;

  @override
  Future<LatestRatesSnapshot?> readCached(String base) async => cached;

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async {
    if (shouldFail || fresh == null) {
      throw StateError('offline');
    }
    return fresh!;
  }
}
