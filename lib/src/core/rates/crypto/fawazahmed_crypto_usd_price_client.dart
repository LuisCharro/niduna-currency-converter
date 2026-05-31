import 'dart:convert';

import 'package:http/http.dart' as http;

import 'crypto_asset.dart';
import 'crypto_usd_price_client.dart';
import 'crypto_usd_price_snapshot.dart';

class FawazahmedCryptoUsdPriceClient implements CryptoUsdPriceClient {
  FawazahmedCryptoUsdPriceClient({http.Client? client})
    : _client = client ?? http.Client();

  static final List<Uri> _urls = <Uri>[
    Uri.parse(
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
    ),
    Uri.parse('https://latest.currency-api.pages.dev/v1/currencies/usd.json'),
  ];

  final http.Client _client;

  @override
  Future<CryptoUsdPriceSnapshot> fetchUsdPrices() async {
    Object? lastError;
    for (final url in _urls) {
      try {
        final response = await _client.get(url);
        if (response.statusCode != 200) {
          throw CryptoUsdPriceException(
            'fawazahmed0 returned ${response.statusCode}',
          );
        }

        final json = jsonDecode(response.body);
        if (json is! Map<String, dynamic>) {
          throw const CryptoUsdPriceException('fawazahmed0 returned invalid payload');
        }

        final usd = json['usd'];
        final date = json['date'];
        if (usd is! Map<String, dynamic>) {
          throw const CryptoUsdPriceException('fawazahmed0 missing usd rates');
        }

        final pricesUsd = <String, double>{};
        for (final asset in supportedCryptoAssets) {
          final rawRate = usd[asset.code.toLowerCase()];
          if (rawRate is! num || rawRate <= 0) continue;
          pricesUsd[asset.code] = 1 / rawRate.toDouble();
        }

        if (pricesUsd.length < 2) {
          throw const CryptoUsdPriceException('fawazahmed0 returned too few crypto rates');
        }
        _validate(pricesUsd);

        return CryptoUsdPriceSnapshot(
          provider: 'fawazahmed0',
          savedAt: DateTime.tryParse('${date ?? ''}T00:00:00.000') ?? DateTime.now(),
          pricesUsd: pricesUsd,
        );
      } catch (error) {
        lastError = error;
      }
    }

    throw CryptoUsdPriceException(
      'fawazahmed0 fallback failed: ${lastError ?? 'unknown error'}',
    );
  }

  void _validate(Map<String, double> pricesUsd) {
    if (!pricesUsd.containsKey('BTC')) {
      throw const CryptoUsdPriceException('fawazahmed0 missing BTC prices');
    }
    final btc = pricesUsd['BTC']!;
    if (btc < 1000 || btc > 1000000) {
      throw const CryptoUsdPriceException('fawazahmed0 returned implausible BTC price');
    }
    for (final entry in pricesUsd.entries) {
      if (entry.value.isNaN || entry.value <= 0) {
        throw CryptoUsdPriceException(
          'fawazahmed0 returned invalid price for ${entry.key}',
        );
      }
    }
  }
}
