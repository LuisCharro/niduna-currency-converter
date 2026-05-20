import 'dart:convert';

import 'package:http/http.dart' as http;

import 'crypto_asset.dart';
import 'crypto_usd_history_client.dart';
import 'crypto_usd_history_snapshot.dart';

/// CoinCap.io history client for crypto/USD daily historical data.
///
/// CoinCap uses different IDs from CoinPaprika (e.g. 'bitcoin' vs 'btc-bitcoin').
/// The [CryptoAsset.coinCapId] field provides the correct CoinCap asset ID.
///
/// Data is returned as daily OHLC candles. We extract the closing price only.
class CoincapCryptoUsdHistoryClient implements CryptoUsdHistoryClient {
  CoincapCryptoUsdHistoryClient({http.Client? client})
    : _client = client ?? http.Client();

  static const String _baseUrl = 'https://api.coincap.io/v2';

  final http.Client _client;

  @override
  Future<CryptoUsdHistorySnapshot> fetchUsdHistory({
    required String code,
    required DateTime from,
    required DateTime to,
  }) async {
    final asset = cryptoAssetByCode(code);
    final uri = Uri.parse('$_baseUrl/assets/${asset.coinCapId}/history').replace(
      queryParameters: {
        'interval': 'd1',
        'start': from.millisecondsSinceEpoch.toString(),
        'end': to.millisecondsSinceEpoch.toString(),
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw CryptoUsdHistoryException(
        'CoinCap historical returned ${response.statusCode} for $code',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw CryptoUsdHistoryException(
        'CoinCap historical returned invalid payload for $code',
      );
    }

    final data = json['data'];
    if (data is! List<dynamic>) {
      throw CryptoUsdHistoryException(
        'CoinCap historical missing data array for $code',
      );
    }

    final pricesUsd = <DateTime, double>{};
    for (final row in data) {
      if (row is! Map<String, dynamic>) continue;

      // priceUsd is a String in CoinCap responses
      final priceStr = row['priceUsd'] as String?;
      final dateStr = row['date'] as String?;

      if (priceStr == null || dateStr == null) continue;

      // CoinCap returns ISO date string like "2025-01-01T00:00:00.000Z"
      final timestamp = DateTime.tryParse(dateStr);
      final price = double.tryParse(priceStr);

      if (timestamp == null || price == null || price <= 0) continue;

      final normalizedDate = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
      );
      pricesUsd[normalizedDate] = price;
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
        'CoinCap historical returned no data for $code',
      );
    }
    // Same plausibility bounds as CoinPaprika
    final min = code == 'BTC' ? 1000.0 : 50.0;
    final max = code == 'BTC' ? 1000000.0 : 100000.0;
    for (final price in pricesUsd.values) {
      if (price.isNaN || price <= 0 || price < min || price > max) {
        throw CryptoUsdHistoryException(
          'CoinCap historical returned implausible prices for $code',
        );
      }
    }
  }
}