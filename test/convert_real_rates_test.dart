import 'dart:convert';

import 'package:currency_converter/src/core/currency/supported_currencies.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/data/frankfurter_latest_rates_client.dart';
import 'package:currency_converter/src/features/convert/domain/convert_quote_builder.dart';
import 'package:currency_converter/src/features/convert/domain/convert_state.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:currency_converter/src/features/convert/domain/rate_freshness.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('supported currencies match Phase 1 fiat scope', () {
    final codes = supportedCurrencies.map((currency) => currency.code).toSet();

    expect(codes, hasLength(34));
    expect(
      codes,
      containsAll(<String>[
        // Major
        'USD',
        'EUR',
        'GBP',
        'JPY',
        'CNY',
        // Europe
        'CHF',
        'SEK',
        'NOK',
        'DKK',
        'PLN',
        'CZK',
        'HUF',
        'RON',
        // Americas
        'CAD',
        'AUD',
        'MXN',
        'BRL',
        'ARS',
        'CLP',
        'COP',
        // Asia Pacific
        'INR',
        'SGD',
        'HKD',
        'KRW',
        'THB',
        'PHP',
        'IDR',
        'MYR',
        'TWD',
        'NZD',
        // Middle East & Africa
        'TRY',
        'AED',
        'ILS',
        'ZAR',
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
    expect(controller.state.lastUpdatedLabel, 'Rates from May 8');
    expect(
      controller.state.nextUpdateLabel,
      'Checks automatically the first time you open the app each day',
    );
  });

  test('rate freshness formats date-only updates without fake midnight', () {
    final label = RateFreshness.updatedLabel(
      rateDate: DateTime(2026, 5, 8),
      savedAt: DateTime(2026, 5, 8, 9),
    );

    expect(label, 'Rates from May 8');
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

  test('controller reformats quotes when decimal places change', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(
        fresh: _snapshot(<String, double>{'EUR': .923456}),
      ),
      selectedCodes: <String>['EUR'],
    );

    await controller.load();
    expect(controller.state.quotes.single.amount, '92.35');

    controller.setDecimalPlaces(4);

    expect(controller.state.quotes.single.amount, '92.3456');
    expect(controller.state.quotes.single.rateLine, '1 USD = 0.9235 EUR');
  });

  test('controller treats cleared amount as zero', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(
        fresh: _snapshot(<String, double>{'EUR': .92}),
      ),
      selectedCodes: <String>['EUR'],
    );

    await controller.load();
    controller.setAmountText('');

    expect(controller.state.amountText, '');
    expect(controller.state.quotes.single.amount, '0.00');
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

  test('controller adds a crypto currency selected by the user', () async {
    final controller = ConvertController(
      repository: _FakeRatesRepository(
        fresh: _snapshot(<String, double>{'EUR': .92, 'ETH': .00042}),
      ),
      selectedCodes: <String>['EUR'],
    );

    await controller.load();
    controller.toggleCode('ETH');

    expect(controller.state.selectedCodes, <String>['EUR', 'ETH']);
    expect(controller.state.quotes.map((quote) => quote.code), <String>[
      'EUR',
      'ETH',
    ]);
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

  test(
    'Frankfurter latest client rejects unexpected or invalid rows',
    () async {
      final client = FrankfurterLatestRatesClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {
                'date': '2026-05-08',
                'base': 'USD',
                'quote': 'EUR',
                'rate': 0.85025,
              },
              {
                'date': '2026-05-08',
                'base': 'EUR',
                'quote': 'EUR',
                'rate': 0.99,
              },
              {'date': '2026-05-08', 'base': 'USD', 'quote': 'XXX', 'rate': 2},
              {'date': '2026-05-08', 'base': 'USD', 'quote': 'GBP', 'rate': 0},
              {'date': 20260508, 'base': 'USD', 'quote': 'JPY', 'rate': 150},
            ]),
            200,
          );
        }),
      );

      final snapshot = await client.fetchLatest('USD');

      expect(snapshot.date, DateTime(2026, 5, 8));
      expect(snapshot.rates, <String, double>{'EUR': 0.85025});
    },
  );

  group('FrankfurterLatestRatesClient.fetchPreviousRates v2', () {
    test('sends path /v2/rates with from, to, base, quotes', () async {
      Uri? capturedUri;
      final client = FrankfurterLatestRatesClient(
        client: MockClient((request) async {
          capturedUri = request.url;
          return http.Response('[]', 200);
        }),
      );

      await client.fetchPreviousRates(
        'USD',
        referenceDate: DateTime(2026, 6, 15),
      );

      expect(capturedUri!.path, '/v2/rates');
      expect(capturedUri!.queryParameters['base'], 'USD');
      expect(capturedUri!.queryParameters['from'], '2026-06-05');
      expect(capturedUri!.queryParameters['to'], '2026-06-15');
      expect(capturedUri!.queryParameters.containsKey('quotes'), isTrue);
      expect(
        capturedUri!.queryParameters['quotes']!.split(','),
        contains('CLP'),
      );
    });

    test(
      'parses v2 row-list shape, picks latest day before reference',
      () async {
        final client = FrankfurterLatestRatesClient(
          client: MockClient((request) async {
            return http.Response(
              jsonEncode(<Map<String, dynamic>>[
                {
                  'date': '2026-06-11',
                  'base': 'USD',
                  'quote': 'CLP',
                  'rate': 920.5,
                },
                {
                  'date': '2026-06-12',
                  'base': 'USD',
                  'quote': 'CLP',
                  'rate': 921.0,
                },
                {
                  'date': '2026-06-15',
                  'base': 'USD',
                  'quote': 'CLP',
                  'rate': 923.8,
                },
              ]),
              200,
            );
          }),
        );

        final rates = await client.fetchPreviousRates(
          'USD',
          referenceDate: DateTime(2026, 6, 15),
        );

        expect(rates, isNotNull);
        expect(rates!['CLP'], 921.0); // 06-12, NOT 06-15 (reference excluded)
      },
    );

    test('all quotes from same date — no mixing across days', () async {
      final client = FrankfurterLatestRatesClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {
                'date': '2026-06-12',
                'base': 'USD',
                'quote': 'EUR',
                'rate': 0.8645,
              },
              {
                'date': '2026-06-12',
                'base': 'USD',
                'quote': 'CLP',
                'rate': 921.0,
              },
              {
                'date': '2026-06-13',
                'base': 'USD',
                'quote': 'EUR',
                'rate': 0.8630,
              },
              {
                'date': '2026-06-13',
                'base': 'USD',
                'quote': 'CLP',
                'rate': 925.0,
              },
            ]),
            200,
          );
        }),
      );

      final rates = await client.fetchPreviousRates(
        'USD',
        referenceDate: DateTime(2026, 6, 15),
      );

      expect(rates!['EUR'], 0.8630); // 06-13 (latest before 06-15)
      expect(rates['CLP'], 925.0);
    });

    test('returns null when no rows before reference', () async {
      final client = FrankfurterLatestRatesClient(
        client: MockClient((request) async {
          return http.Response('[]', 200);
        }),
      );

      final rates = await client.fetchPreviousRates(
        'USD',
        referenceDate: DateTime(2026, 6, 15),
      );

      expect(rates, isNull);
    });

    test(
      'returns null when payload only contains reference or future rows',
      () async {
        final client = FrankfurterLatestRatesClient(
          client: MockClient((request) async {
            return http.Response(
              jsonEncode(<Map<String, dynamic>>[
                {
                  'date': '2026-06-15',
                  'base': 'USD',
                  'quote': 'EUR',
                  'rate': 0.8634,
                },
                {
                  'date': '2026-06-16',
                  'base': 'USD',
                  'quote': 'EUR',
                  'rate': 0.8620,
                },
              ]),
              200,
            );
          }),
        );

        final rates = await client.fetchPreviousRates(
          'USD',
          referenceDate: DateTime(2026, 6, 15),
        );

        expect(rates, isNull);
      },
    );

    test(
      'ignores invalid dates, wrong bases, unsupported quotes and rates',
      () async {
        final client = FrankfurterLatestRatesClient(
          client: MockClient((request) async {
            return http.Response(
              jsonEncode(<Map<String, dynamic>>[
                {'date': 'bad', 'base': 'USD', 'quote': 'EUR', 'rate': 0.8},
                {
                  'date': '2026-06-12',
                  'base': 'EUR',
                  'quote': 'CLP',
                  'rate': 921.0,
                },
                {
                  'date': '2026-06-12',
                  'base': 'USD',
                  'quote': 'XXX',
                  'rate': 1.0,
                },
                {
                  'date': '2026-06-12',
                  'base': 'USD',
                  'quote': 'EUR',
                  'rate': 0,
                },
                {
                  'date': '2026-06-12',
                  'base': 'USD',
                  'quote': 'CLP',
                  'rate': 921.0,
                },
              ]),
              200,
            );
          }),
        );

        final rates = await client.fetchPreviousRates(
          'USD',
          referenceDate: DateTime(2026, 6, 15),
        );

        expect(rates, <String, double>{'CLP': 921.0});
      },
    );

    test('CLP, AED, ARS, COP, TWD returned in v2 row payload', () async {
      final client = FrankfurterLatestRatesClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {
                'date': '2026-06-12',
                'base': 'USD',
                'quote': 'CLP',
                'rate': 921.0,
              },
              {
                'date': '2026-06-12',
                'base': 'USD',
                'quote': 'AED',
                'rate': 3.6725,
              },
              {
                'date': '2026-06-12',
                'base': 'USD',
                'quote': 'ARS',
                'rate': 880.0,
              },
              {
                'date': '2026-06-12',
                'base': 'USD',
                'quote': 'COP',
                'rate': 4100.0,
              },
              {
                'date': '2026-06-12',
                'base': 'USD',
                'quote': 'TWD',
                'rate': 32.5,
              },
            ]),
            200,
          );
        }),
      );

      final rates = await client.fetchPreviousRates(
        'USD',
        referenceDate: DateTime(2026, 6, 15),
      );

      expect(rates!.containsKey('CLP'), isTrue);
      expect(rates.containsKey('AED'), isTrue);
      expect(rates.containsKey('ARS'), isTrue);
      expect(rates.containsKey('COP'), isTrue);
      expect(rates.containsKey('TWD'), isTrue);
    });

    test('malformed/empty/non-200 → null (graceful degradation)', () async {
      final client404 = FrankfurterLatestRatesClient(
        client: MockClient((request) async => http.Response('not found', 404)),
      );
      expect(
        await client404.fetchPreviousRates(
          'USD',
          referenceDate: DateTime(2026, 6, 15),
        ),
        isNull,
      );

      final clientBadJson = FrankfurterLatestRatesClient(
        client: MockClient((request) async => http.Response('not json', 200)),
      );
      expect(
        await clientBadJson.fetchPreviousRates(
          'USD',
          referenceDate: DateTime(2026, 6, 15),
        ),
        isNull,
      );
    });
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

  @override
  Future<void> cacheSnapshot(LatestRatesSnapshot snapshot) async {}

  @override
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) async => null;
}
