import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/currency/supported_currencies.dart';
import '../models/rates_snapshot.dart';
import '../rates_client.dart';

class FrankfurterClient implements RatesClient {
  FrankfurterClient({http.Client? client}) : _client = client ?? http.Client();

  static const String _host = 'api.frankfurter.dev';

  final http.Client _client;

  @override
  Future<RatesSnapshot> fetchLatest(String base) async {
    if (!isFiatCurrency(base)) {
      throw RatesClientException('Frankfurter latest does not support $base');
    }
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
      throw RatesClientException('Frankfurter returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    if (json is! List<dynamic>) {
      throw const RatesClientException('Invalid latest-rates payload');
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
      throw const RatesClientException('No supported rates in payload');
    }

    return RatesSnapshot(
      base: base,
      date: date,
      savedAt: DateTime.now(),
      rates: rates,
    );
  }

  @override
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    if (base == quote) {
      // Identity shortcut: USD/USD = 1 across the requested range.
      // Avoids hitting Frankfurter for a no-op conversion that the
      // MultiProviderRatesClient already short-circuits in mixed pairs.
      final day = DateTime(from.year, from.month, from.day);
      return HistoricalSnapshot(
        base: base,
        quote: quote,
        coveredFrom: day,
        coveredTo: day,
        data: <DateTime, double>{day: 1.0},
        savedAt: DateTime.now(),
      );
    }
    if (!isFiatCurrency(base) || !isFiatCurrency(quote)) {
      throw RatesClientException(
        'Frankfurter historical does not support $base/$quote',
      );
    }
    final fromStr = from.toIso8601String().split('T').first;
    final toStr = to.toIso8601String().split('T').first;

    final uri = Uri.https(_host, '/v2/rates', <String, String>{
      'from': fromStr,
      'to': toStr,
      'base': base,
      'quotes': quote,
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw RatesClientException(
        'Frankfurter historical returned ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! List) {
      throw const RatesClientException('Invalid historical payload');
    }

    final data = <DateTime, double>{};
    for (final row in json) {
      if (row is! Map<String, dynamic>) continue;
      final dateStr = row['date'];
      final rowQuote = row['quote'];
      final rate = row['rate'];
      if (dateStr is! String || rowQuote is! String || rate is! num) continue;
      if (rowQuote != quote) continue;
      final date = DateTime.tryParse(dateStr.split('T').first);
      if (date == null) continue;
      data[date] = rate.toDouble();
    }

    if (data.isEmpty) {
      throw const RatesClientException('No historical rates in payload');
    }

    final coveredFrom = data.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final coveredTo = data.keys.reduce((a, b) => a.isAfter(b) ? a : b);
    return HistoricalSnapshot(
      base: base,
      quote: quote,
      coveredFrom: coveredFrom,
      coveredTo: coveredTo,
      data: data,
      savedAt: DateTime.now(),
    );
  }
}
