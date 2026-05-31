import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'crypto_asset.dart';
import 'crypto_usd_history_client.dart';
import 'crypto_usd_history_snapshot.dart';

class FawazahmedCryptoUsdHistoryClient implements CryptoUsdHistoryClient {
  FawazahmedCryptoUsdHistoryClient({http.Client? client})
    : _client = client ?? http.Client();

  static const String _cdnBase =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@{date}/v1/currencies/usd.min.json';
  static const String _fallbackBase =
      'https://{date}.currency-api.pages.dev/v1/currencies/usd.min.json';

  static const int _concurrencyLimit = 10;

  final http.Client _client;

  @override
  Future<CryptoUsdHistorySnapshot> fetchUsdHistory({
    required String code,
    required DateTime from,
    required DateTime to,
  }) async {
    final asset = cryptoAssetByCode(code);
    final dates = _dateRange(from, to);

    final pricesUsd = <DateTime, double>{};
    var lastSuccessfulDate = from;

    for (final batch in _chunks(dates, _concurrencyLimit)) {
      final results = await Future.wait(
        batch.map((date) => _fetchDay(asset, date)),
      );

      for (final result in results) {
        if (result != null) {
          pricesUsd[result.key] = result.value;
          if (result.key.isAfter(lastSuccessfulDate)) {
            lastSuccessfulDate = result.key;
          }
        }
      }
    }

    _validate(code, pricesUsd);

    return CryptoUsdHistorySnapshot(
      code: code,
      coveredFrom: pricesUsd.keys.reduce((a, b) => a.isBefore(b) ? a : b),
      coveredTo: lastSuccessfulDate,
      savedAt: DateTime.now(),
      pricesUsd: pricesUsd,
    );
  }

  Future<MapEntry<DateTime, double>?> _fetchDay(
    CryptoAsset asset,
    DateTime date,
  ) async {
    final dateStr = _formatDate(date);
    for (final urlTemplate in [_cdnBase, _fallbackBase]) {
      try {
        final url = Uri.parse(urlTemplate.replaceAll('{date}', dateStr));
        final response = await _client.get(url);

        if (response.statusCode == 404) continue;
        if (response.statusCode != 200) continue;

        final json = jsonDecode(response.body);
        if (json is! Map<String, dynamic>) continue;

        final usd = json['usd'];
        if (usd is! Map<String, dynamic>) continue;

        final btc = usd[asset.code.toLowerCase()];
        if (btc is! num || btc <= 0) continue;

        final priceUsd = 1 / btc.toDouble();
        return MapEntry(date, priceUsd);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  void _validate(String code, Map<DateTime, double> pricesUsd) {
    if (pricesUsd.isEmpty) {
      throw CryptoUsdHistoryException(
        'fawazahmed0 returned no data for $code',
      );
    }
    final isBtc = code == 'BTC';
    final min = isBtc ? 1000.0 : 0.001;
    final max = isBtc ? 1000000.0 : 100000.0;
    for (final price in pricesUsd.values) {
      if (price.isNaN || price <= 0 || price < min || price > max) {
        throw CryptoUsdHistoryException(
          'fawazahmed0 returned implausible prices for $code',
        );
      }
    }
  }

  static List<DateTime> _dateRange(DateTime from, DateTime to) {
    final dates = <DateTime>[];
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!cursor.isAfter(end)) {
      dates.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return dates;
  }

  static List<List<T>> _chunks<T>(List<T> items, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < items.length; i += size) {
      chunks.add(items.sublist(i, (i + size).clamp(0, items.length)));
    }
    return chunks;
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${_pad(date.month)}-${_pad(date.day)}';

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
