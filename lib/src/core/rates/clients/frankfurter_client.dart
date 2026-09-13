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
    final requestedQuotes = quotes.split(',').toSet();
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
      if (row is! Map<String, dynamic>) continue;
      final rowBase = row['base'];
      final quote = row['quote'];
      final rate = row['rate'];
      final rawDate = row['date'];
      final rowDate = rawDate is String ? DateTime.tryParse(rawDate) : null;
      if (rowBase != base ||
          quote is! String ||
          !requestedQuotes.contains(quote) ||
          rate is! num ||
          rate <= 0 ||
          rowDate == null) {
        continue;
      }
      rates[quote] = rate.toDouble();
      if (date == null || rowDate.isAfter(date)) date = rowDate;
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
    final fromDay = DateTime(from.year, from.month, from.day);
    final toDay = DateTime(to.year, to.month, to.day);
    if (base == quote) {
      final data = <DateTime, double>{};
      var day = fromDay;
      final lastDay = toDay;
      while (!day.isAfter(lastDay)) {
        data[day] = 1;
        day = day.add(const Duration(days: 1));
      }
      if (data.isEmpty) {
        throw const RatesClientException('Invalid historical date range');
      }
      return HistoricalSnapshot(
        base: base,
        quote: quote,
        coveredFrom: data.keys.first,
        coveredTo: data.keys.last,
        data: data,
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
      final rowBase = row['base'];
      final rowQuote = row['quote'];
      final rate = row['rate'];
      if (dateStr is! String ||
          rowBase is! String ||
          rowQuote is! String ||
          rate is! num ||
          rate <= 0) {
        continue;
      }
      if (rowBase != base || rowQuote != quote) continue;
      final date = DateTime.tryParse(dateStr.split('T').first);
      if (date == null || date.isBefore(fromDay) || date.isAfter(toDay)) {
        continue;
      }
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
