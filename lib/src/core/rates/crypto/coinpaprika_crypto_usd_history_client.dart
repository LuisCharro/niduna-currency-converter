import 'dart:convert';

import 'package:http/http.dart' as http;

import 'crypto_asset.dart';
import 'crypto_usd_history_client.dart';
import 'crypto_usd_history_snapshot.dart';

class CoinPaprikaCryptoUsdHistoryClient implements CryptoUsdHistoryClient {
  CoinPaprikaCryptoUsdHistoryClient({http.Client? client})
    : _client = client ?? http.Client();

  static const String _host = 'api.coinpaprika.com';

  final http.Client _client;

  @override
  Future<CryptoUsdHistorySnapshot> fetchUsdHistory({
    required String code,
    required DateTime from,
    required DateTime to,
  }) async {
    final asset = cryptoAssetByCode(code);
    final uri = Uri.https(
      _host,
      '/v1/tickers/${asset.coinPaprikaId}/historical',
      {
        'start': _dateOnly(from),
        'end': _dateOnly(to),
        'interval': '1d',
        'quote': 'usd',
      },
    );
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw CryptoUsdHistoryException(
        'CoinPaprika historical returned ${response.statusCode} for $code',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! List<dynamic>) {
      throw CryptoUsdHistoryException(
        'CoinPaprika historical returned invalid payload for $code',
      );
    }

    final pricesUsd = <DateTime, double>{};
    for (final row in json) {
      if (row is! Map<String, dynamic>) continue;
      final timestamp = DateTime.tryParse((row['timestamp'] as String?) ?? '');
      final price = row['price'];
      if (timestamp == null || price is! num) continue;
      final normalizedDate = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
      );
      pricesUsd[normalizedDate] = price.toDouble();
    }

    _validate(code, pricesUsd);

    final coveredFrom = pricesUsd.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final coveredTo = pricesUsd.keys.reduce((a, b) => a.isAfter(b) ? a : b);
    return CryptoUsdHistorySnapshot(
      code: code,
      coveredFrom: coveredFrom,
      coveredTo: coveredTo,
      savedAt: DateTime.now(),
      pricesUsd: pricesUsd,
    );
  }

  String _dateOnly(DateTime value) => value.toIso8601String().split('T').first;

  void _validate(String code, Map<DateTime, double> pricesUsd) {
    if (pricesUsd.isEmpty) {
      throw CryptoUsdHistoryException(
        'CoinPaprika historical returned no data for $code',
      );
    }
    final isBtc = code == 'BTC';
    final min = isBtc ? 1000.0 : 0.001;
    final max = isBtc ? 1000000.0 : 100000.0;
    for (final price in pricesUsd.values) {
      if (price.isNaN || price <= 0 || price < min || price > max) {
        throw CryptoUsdHistoryException(
          'CoinPaprika historical returned implausible prices for $code',
        );
      }
    }
  }
}
