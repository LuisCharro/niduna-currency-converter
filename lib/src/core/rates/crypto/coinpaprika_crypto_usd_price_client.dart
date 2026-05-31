import 'dart:convert';

import 'package:http/http.dart' as http;

import 'crypto_asset.dart';
import 'crypto_usd_price_client.dart';
import 'crypto_usd_price_snapshot.dart';

class CoinPaprikaCryptoUsdPriceClient implements CryptoUsdPriceClient {
  CoinPaprikaCryptoUsdPriceClient({http.Client? client})
    : _client = client ?? http.Client();

  static const String _host = 'api.coinpaprika.com';

  final http.Client _client;

  @override
  Future<CryptoUsdPriceSnapshot> fetchUsdPrices() async {
    final responses = await Future.wait(
      supportedCryptoAssets.map(_fetchAsset),
    );
    final pricesUsd = <String, double>{};
    DateTime? savedAt;

    for (final response in responses) {
      pricesUsd[response.code] = response.priceUsd;
      savedAt ??= response.savedAt;
    }

    _validate(pricesUsd);

    return CryptoUsdPriceSnapshot(
      provider: 'coinpaprika',
      savedAt: savedAt ?? DateTime.now(),
      pricesUsd: pricesUsd,
    );
  }

  Future<_AssetResponse> _fetchAsset(CryptoAsset asset) async {
    final uri = Uri.https(_host, '/v1/tickers/${asset.coinPaprikaId}', {
      'quotes': 'USD',
    });
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw CryptoUsdPriceException(
        'CoinPaprika returned ${response.statusCode} for ${asset.code}',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw CryptoUsdPriceException(
        'CoinPaprika returned invalid payload for ${asset.code}',
      );
    }

    final symbol = json['symbol'];
    final quotes = json['quotes'];
    final usd = quotes is Map<String, dynamic> ? quotes['USD'] : null;
    final price = usd is Map<String, dynamic> ? usd['price'] : null;
    if (symbol != asset.code || price is! num) {
      throw CryptoUsdPriceException(
        'CoinPaprika missing USD price for ${asset.code}',
      );
    }

    return _AssetResponse(
      code: asset.code,
      priceUsd: price.toDouble(),
      savedAt: DateTime.tryParse((json['last_updated'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  void _validate(Map<String, double> pricesUsd) {
    if (!pricesUsd.containsKey('BTC')) {
      throw const CryptoUsdPriceException('CoinPaprika missing BTC price');
    }
    final btc = pricesUsd['BTC']!;
    if (btc < 1000 || btc > 1000000) {
      throw const CryptoUsdPriceException('CoinPaprika returned implausible BTC price');
    }
    for (final entry in pricesUsd.entries) {
      if (entry.value.isNaN || entry.value <= 0) {
        throw CryptoUsdPriceException(
          'CoinPaprika returned invalid price for ${entry.key}',
        );
      }
    }
  }
}

class _AssetResponse {
  const _AssetResponse({
    required this.code,
    required this.priceUsd,
    required this.savedAt,
  });

  final String code;
  final double priceUsd;
  final DateTime savedAt;
}
