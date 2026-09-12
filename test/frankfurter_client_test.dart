import 'dart:convert';

import 'package:currency_converter/src/core/rates/clients/frankfurter_client.dart';
import 'package:currency_converter/src/core/rates/rates_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('FrankfurterClient.fetchHistorical v2', () {
    test('sends path /v2/rates', () async {
      Uri? capturedUri;
      final mock = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            {'date': '2026-09-10', 'base': 'USD', 'quote': 'CLP', 'rate': 934.12},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = FrankfurterClient(client: mock);
      await client.fetchHistorical(
        base: 'USD',
        quote: 'CLP',
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 10),
      );
      expect(capturedUri!.path, '/v2/rates');
    });

    test('sends base, quotes, from, to query parameters', () async {
      Uri? capturedUri;
      final mock = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            {'date': '2026-09-10', 'base': 'USD', 'quote': 'CLP', 'rate': 934.12},
          ]),
          200,
        );
      });
      final client = FrankfurterClient(client: mock);
      await client.fetchHistorical(
        base: 'USD',
        quote: 'CLP',
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 10),
      );
      expect(capturedUri!.queryParameters['base'], 'USD');
      expect(capturedUri!.queryParameters['quotes'], 'CLP');
      expect(capturedUri!.queryParameters['from'], '2026-09-01');
      expect(capturedUri!.queryParameters['to'], '2026-09-10');
    });

    test('does not send v1 symbols parameter or encode range in path', () async {
      Uri? capturedUri;
      final mock = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            {'date': '2026-09-10', 'base': 'USD', 'quote': 'CLP', 'rate': 934.12},
          ]),
          200,
        );
      });
      final client = FrankfurterClient(client: mock);
      await client.fetchHistorical(
        base: 'USD',
        quote: 'CLP',
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 10),
      );
      expect(capturedUri!.path, isNot(matches(RegExp(r'/v1/.*\.\.'))));
      expect(capturedUri!.queryParameters.containsKey('symbols'), isFalse);
    });

    test('parses v2 row list shape for USD → CLP into date/value points', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            {'date': '2026-09-08', 'base': 'USD', 'quote': 'CLP', 'rate': 932.5},
            {'date': '2026-09-09', 'base': 'USD', 'quote': 'CLP', 'rate': 933.8},
            {'date': '2026-09-10', 'base': 'USD', 'quote': 'CLP', 'rate': 934.12},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = FrankfurterClient(client: mock);
      final snapshot = await client.fetchHistorical(
        base: 'USD',
        quote: 'CLP',
        from: DateTime(2026, 9, 8),
        to: DateTime(2026, 9, 10),
      );
      expect(snapshot.data.length, 3);
      expect(snapshot.data[DateTime(2026, 9, 8)], 932.5);
      expect(snapshot.data[DateTime(2026, 9, 10)], 934.12);
    });

    test('computes coveredFrom and coveredTo from valid parsed rows', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            {'date': '2026-09-08', 'base': 'USD', 'quote': 'CLP', 'rate': 932.5},
            {'date': '2026-09-10', 'base': 'USD', 'quote': 'CLP', 'rate': 934.12},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = FrankfurterClient(client: mock);
      final snapshot = await client.fetchHistorical(
        base: 'USD',
        quote: 'CLP',
        from: DateTime(2026, 9, 8),
        to: DateTime(2026, 9, 10),
      );
      expect(snapshot.coveredFrom, DateTime(2026, 9, 8));
      expect(snapshot.coveredTo, DateTime(2026, 9, 10));
    });

    test('ignores malformed rows without discarding valid rows', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            {'date': '2026-09-08', 'base': 'USD', 'quote': 'CLP', 'rate': 932.5},
            {'date': 'bad-date', 'base': 'USD', 'quote': 'CLP', 'rate': 933.0},
            {'date': '2026-09-09', 'base': 'USD', 'quote': 'OTHER', 'rate': 933.5},
            {'quote': 'CLP', 'rate': 933.7},
            {'date': '2026-09-10', 'base': 'USD', 'quote': 'CLP', 'rate': 934.12},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = FrankfurterClient(client: mock);
      final snapshot = await client.fetchHistorical(
        base: 'USD',
        quote: 'CLP',
        from: DateTime(2026, 9, 8),
        to: DateTime(2026, 9, 10),
      );
      expect(snapshot.data.length, 2);
      expect(snapshot.data[DateTime(2026, 9, 8)], 932.5);
      expect(snapshot.data[DateTime(2026, 9, 10)], 934.12);
    });

    test('throws RatesClientException for non-list payload', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{'rates': <String, dynamic>{}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = FrankfurterClient(client: mock);
      await expectLater(
        client.fetchHistorical(
          base: 'USD',
          quote: 'CLP',
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 10),
        ),
        throwsA(isA<RatesClientException>()),
      );
    });

    test('throws RatesClientException when no valid rows remain', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            {'date': 'bad-date', 'rate': 100},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = FrankfurterClient(client: mock);
      await expectLater(
        client.fetchHistorical(
          base: 'USD',
          quote: 'CLP',
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 10),
        ),
        throwsA(isA<RatesClientException>()),
      );
    });

    test('rejects fiat/crypto request at this client boundary', () async {
      final mock = MockClient((request) async {
        return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
      });
      final client = FrankfurterClient(client: mock);
      await expectLater(
        client.fetchHistorical(
          base: 'USD',
          quote: 'BTC',
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 10),
        ),
        throwsA(isA<RatesClientException>()),
      );
    });

    test('handles base == quote identity (USD/USD) without inventing network request',
        () async {
      var callCount = 0;
      final mock = MockClient((request) async {
        callCount++;
        return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
      });
      final client = FrankfurterClient(client: mock);
      final snapshot = await client.fetchHistorical(
        base: 'USD',
        quote: 'USD',
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 10),
      );
      expect(snapshot.data.values.every((r) => r == 1.0), isTrue);
      expect(callCount, 0, reason: 'Identity shortcut: no HTTP call expected');
    });
  });
}
