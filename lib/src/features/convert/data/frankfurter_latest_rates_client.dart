import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/currency/supported_currencies.dart';
import '../domain/latest_rates_snapshot.dart';

class FrankfurterLatestRatesClient {
  FrankfurterLatestRatesClient({http.Client? client})
    : _client = client ?? http.Client();

  static const String _host = 'api.frankfurter.dev';

  final http.Client _client;

  Future<LatestRatesSnapshot> fetchLatest(String base) async {
    currencyByCode(base);
    final quotes = supportedCurrencies
        .where((currency) => currency.code != base)
        .map((currency) => currency.code)
        .join(',');
    final uri = Uri.https(_host, '/v2/rates', <String, String>{
      'base': base,
      'quotes': quotes,
    });
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw LatestRatesException('Frankfurter returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    if (json is! List<dynamic>) {
      throw const LatestRatesException('Invalid latest-rates payload');
    }

    DateTime? date;
    final rates = <String, double>{};
    for (final row in json) {
      if (row is Map<String, dynamic>) {
        final quote = row['quote'];
        final rate = row['rate'];
        if (quote is String && rate is num) {
          rates[quote] = rate.toDouble();
        }
        date ??= DateTime.tryParse((row['date'] as String?) ?? '');
      }
    }

    if (rates.isEmpty) {
      throw const LatestRatesException('No supported rates in payload');
    }

    return LatestRatesSnapshot(
      base: base,
      date: date,
      savedAt: DateTime.now(),
      rates: rates,
    );
  }
}

class LatestRatesException implements Exception {
  const LatestRatesException(this.message);

  final String message;

  @override
  String toString() => message;
}
