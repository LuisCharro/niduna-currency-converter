import 'dart:convert';

import 'package:http/http.dart' as http;

import 'crypto_asset.dart';
import 'crypto_usd_history_client.dart';
import 'crypto_usd_history_snapshot.dart';

/// CoinGecko history client for crypto/USD daily historical data.
///
/// CoinGecko uses the same asset IDs as CoinCap's `coinCapId` field
/// (e.g. 'bitcoin', 'ethereum'), so no changes to CryptoAsset are needed.
class CoingeckoCryptoUsdHistoryClient implements CryptoUsdHistoryClient {
  CoingeckoCryptoUsdHistoryClient({http.Client? client})
    : _client = client ?? http.Client();

  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  final http.Client _client;

  @override
  Future<CryptoUsdHistorySnapshot> fetchUsdHistory({
    required String code,
    required DateTime from,
    required DateTime to,
  }) async {
    final asset = cryptoAssetByCode(code);
    // Use days-based endpoint — automatically returns daily granularity for ranges > 90 days
    final days = to.difference(from).inDays + 1;
    final uri = Uri.parse('$_baseUrl/coins/${asset.coinCapId}/market_chart')
        .replace(queryParameters: {
      'vs_currency': 'usd',
      'days': days.toString(),
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw CryptoUsdHistoryException(
        'CoinGecko returned ${response.statusCode} for $code',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw CryptoUsdHistoryException(
        'CoinGecko returned invalid payload for $code',
      );
    }

    final prices = json['prices'];
    if (prices is! List<dynamic>) {
      throw CryptoUsdHistoryException(
        'CoinGecko missing prices array for $code',
      );
    }

    final pricesUsd = <DateTime, double>{};
    for (final entry in prices) {
      if (entry is! List<dynamic> || entry.length < 2) continue;

      // CoinGecko returns [unix_ms_timestamp, price_usd]
      final ts = entry[0];
      final price = entry[1];

      if (ts is! num || price is! num) continue;

      final timestamp = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
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

  void _validate(String code, Map<DateTime, double> pricesUsd) {
    if (pricesUsd.isEmpty) {
      throw CryptoUsdHistoryException(
        'CoinGecko returned no data for $code',
      );
    }
    // Same plausibility bounds as CoinPaprika and the old CoinCap client
    final min = code == 'BTC' ? 1000.0 : 50.0;
    final max = code == 'BTC' ? 1000000.0 : 100000.0;
    for (final price in pricesUsd.values) {
      if (price.isNaN || price <= 0 || price < min || price > max) {
        throw CryptoUsdHistoryException(
          'CoinGecko returned implausible prices for $code',
        );
      }
    }
  }
}