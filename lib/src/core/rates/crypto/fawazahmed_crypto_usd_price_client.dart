import 'dart:convert';

import 'package:http/http.dart' as http;

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

        final btc = usd['btc'];
        final eth = usd['eth'];
        if (btc is! num || eth is! num || btc <= 0 || eth <= 0) {
          throw const CryptoUsdPriceException('fawazahmed0 missing BTC/ETH rates');
        }

        final pricesUsd = <String, double>{
          'BTC': 1 / btc.toDouble(),
          'ETH': 1 / eth.toDouble(),
        };
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
    final btc = pricesUsd['BTC'];
    final eth = pricesUsd['ETH'];
    if (btc == null || eth == null) {
      throw const CryptoUsdPriceException('fawazahmed0 missing BTC/ETH prices');
    }
    if (btc < 1000 || btc > 1000000 || eth < 50 || eth > 100000) {
      throw const CryptoUsdPriceException('fawazahmed0 returned implausible prices');
    }
    final ratio = btc / eth;
    if (ratio < 1 || ratio > 200) {
      throw const CryptoUsdPriceException('fawazahmed0 returned implausible BTC/ETH ratio');
    }
  }
}
