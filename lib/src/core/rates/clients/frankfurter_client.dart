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
    final fromStr = from.toIso8601String().split('T').first;
    final toStr = to.toIso8601String().split('T').first;
    final range = '$fromStr..$toStr';

    final uri = Uri.https(_host, '/v1/$range', <String, String>{
      'base': base,
      'symbols': quote,
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw RatesClientException(
        'Frankfurter historical returned ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw const RatesClientException('Invalid historical payload');
    }

    final ratesData = json['rates'] as Map<String, dynamic>?;

    if (ratesData == null) {
      throw const RatesClientException(
        'Invalid historical payload: missing rates',
      );
    }

    final data = <DateTime, double>{};
    for (final entry in ratesData.entries) {
      final date = DateTime.tryParse(entry.key);
      final dayRates = entry.value;
      final rate = dayRates is Map<String, dynamic>
          ? (dayRates[quote] as num?)?.toDouble()
          : null;
      if (date != null && rate != null) {
        data[date] = rate;
      }
    }

    if (data.isEmpty) {
      throw const RatesClientException('No historical rates in payload');
    }

    final rangeKey = '${fromStr}_$toStr';
    return HistoricalSnapshot(
      base: base,
      quote: quote,
      rangeKey: rangeKey,
      data: data,
      savedAt: DateTime.now(),
    );
  }
}
