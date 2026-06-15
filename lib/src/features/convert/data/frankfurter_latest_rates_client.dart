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

  @override
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) async {
    try {
      // A single-date query (/v2/rates/{date}) resolves to the *latest*
      // published rates, so it can't give a prior day. Instead fetch a short
      // time series and take the most recent date strictly before the latest
      // published date (referenceDate) — the true previous business day. This
      // stays meaningful on weekends and before today's ECB publish.
      final reference = referenceDate ?? DateTime.now();
      final referenceStr = _isoDate(reference);
      final startStr = _isoDate(reference.subtract(const Duration(days: 10)));
      final symbols = supportedFiatCurrencies
          .where((currency) => currency.code != base)
          .map((currency) => currency.code)
          .join(',');
      final uri = Uri.https(_host, '/v1/$startStr..$referenceStr', <String, String>{
        'base': base,
        'symbols': symbols,
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) return null;
      final ratesByDate = json['rates'];
      if (ratesByDate is! Map<String, dynamic>) return null;

      // ISO date keys sort chronologically; pick the latest day before the
      // reference, falling back to the overall latest available day.
      String? chosen;
      for (final date in ratesByDate.keys) {
        if (date.compareTo(referenceStr) >= 0) continue;
        if (chosen == null || date.compareTo(chosen) > 0) chosen = date;
      }
      chosen ??= ratesByDate.keys.fold<String?>(
        null,
        (best, d) => best == null || d.compareTo(best) > 0 ? d : best,
      );
      if (chosen == null) return null;

      final dayRates = ratesByDate[chosen];
      if (dayRates is! Map<String, dynamic>) return null;
      final rates = <String, double>{};
      dayRates.forEach((code, value) {
        if (value is num) rates[code] = value.toDouble();
      });
      return rates.isEmpty ? null : rates;
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
