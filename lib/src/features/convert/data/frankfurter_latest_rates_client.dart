import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/currency/supported_currencies.dart';
import '../domain/latest_rates_snapshot.dart';
import 'latest_rates_client.dart';

class FrankfurterLatestRatesClient implements LatestRatesClient {
  FrankfurterLatestRatesClient({http.Client? client})
    : _client = client ?? http.Client();

  static const String _host = 'api.frankfurter.dev';

  final http.Client _client;

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async {
    currencyByCode(base);
    final quotes = supportedFiatCurrencies
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
      throw LatestRatesException('Frankfurter returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    if (json is! List<dynamic>) {
      throw const LatestRatesException('Invalid latest-rates payload');
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
      throw const LatestRatesException('No supported rates in payload');
    }

    return LatestRatesSnapshot(
      base: base,
      date: date,
      savedAt: DateTime.now(),
      rates: rates,
    );
  }

  @override
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) async {
    try {
      // A single-date query (/v2/rates/{date}) resolves to the *latest*
      // published rates, so it can't give a prior day. Instead fetch a short
      // time series (v2 row-list shape) and pick the most recent date strictly
      // before the reference date — the true previous business day. This stays
      // meaningful on weekends and before today's ECB publish.
      final reference = referenceDate ?? DateTime.now();
      final referenceStr = _isoDate(reference);
      final startStr = _isoDate(reference.subtract(const Duration(days: 10)));
      final quotes = supportedFiatCurrencies
          .where((currency) => currency.code != base)
          .map((currency) => currency.code)
          .join(',');
      final requestedQuotes = quotes.split(',').toSet();
      final uri = Uri.https(_host, '/v2/rates', <String, String>{
        'from': startStr,
        'to': referenceStr,
        'base': base,
        'quotes': quotes,
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body);
      if (json is! List<dynamic>) return null;

      // Group v2 rows by date; row order is not a contract so we rebuild
      // the per-day map explicitly.
      final byDate = <DateTime, Map<String, double>>{};
      final start = DateTime(
        reference.year,
        reference.month,
        reference.day,
      ).subtract(const Duration(days: 10));
      final referenceDay = DateTime(
        reference.year,
        reference.month,
        reference.day,
      );
      for (final row in json) {
        if (row is! Map<String, dynamic>) continue;
        final dateStr = row['date'];
        final rowBase = row['base'];
        final quote = row['quote'];
        final rate = row['rate'];
        if (dateStr is! String ||
            rowBase != base ||
            quote is! String ||
            !requestedQuotes.contains(quote) ||
            rate is! num ||
            rate <= 0) {
          continue;
        }
        final date = DateTime.tryParse(dateStr.split('T').first);
        if (date == null ||
            date.isBefore(start) ||
            !date.isBefore(referenceDay)) {
          continue;
        }
        final map = byDate.putIfAbsent(date, () => <String, double>{});
        map[quote] = rate.toDouble();
      }

      if (byDate.isEmpty) return null;

      // Pick the latest date strictly before the reference, then return all
      // quotes from that single date — never mix rates across days.
      DateTime? chosen;
      for (final date in byDate.keys) {
        if (chosen == null || date.isAfter(chosen)) chosen = date;
      }
      if (chosen == null) return null;

      final rates = byDate[chosen];
      if (rates == null || rates.isEmpty) return null;
      return rates;
    } catch (_) {
      return null;
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

class LatestRatesException implements Exception {
  const LatestRatesException(this.message);

  final String message;

  @override
  String toString() => message;
}
