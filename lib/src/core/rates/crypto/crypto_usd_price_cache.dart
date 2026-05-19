import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'crypto_usd_price_snapshot.dart';

class CryptoUsdPriceCache {
  CryptoUsdPriceCache(this._preferences);

  static const String _key = 'crypto_usd_prices_v1';

  final SharedPreferences _preferences;

  Future<CryptoUsdPriceSnapshot?> read() async {
    final raw = _preferences.getString(_key);
    if (raw == null) return null;

    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) return null;

    final pricesJson = json['pricesUsd'];
    if (pricesJson is! Map<String, dynamic>) return null;

    final pricesUsd = <String, double>{};
    for (final entry in pricesJson.entries) {
      final value = entry.value;
      if (value is num) {
        pricesUsd[entry.key] = value.toDouble();
      }
    }

    final savedAt = DateTime.tryParse((json['savedAt'] as String?) ?? '');
    final provider = json['provider'] as String?;
    if (savedAt == null || provider == null || pricesUsd.isEmpty) return null;

    return CryptoUsdPriceSnapshot(
      provider: provider,
      savedAt: savedAt,
      pricesUsd: pricesUsd,
    );
  }

  Future<void> write(CryptoUsdPriceSnapshot snapshot) async {
    await _preferences.setString(
      _key,
      jsonEncode(<String, Object?>{
        'provider': snapshot.provider,
        'savedAt': snapshot.savedAt.toIso8601String(),
        'pricesUsd': snapshot.pricesUsd,
      }),
    );
  }
}
