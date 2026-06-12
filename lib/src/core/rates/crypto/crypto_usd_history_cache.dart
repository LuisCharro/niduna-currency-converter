import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'crypto_usd_history_snapshot.dart';

class CryptoUsdHistoryCache {
  CryptoUsdHistoryCache(this._preferences);

  final SharedPreferences _preferences;

  Future<CryptoUsdHistorySnapshot?> read(String code) async {
    final raw = _preferences.getString(_key(code));
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final dataJson = decoded['pricesUsd'];
      if (dataJson is! Map<String, dynamic>) return null;

      final pricesUsd = <DateTime, double>{};
      for (final entry in dataJson.entries) {
        final date = DateTime.tryParse(entry.key);
        final value = entry.value;
        if (date != null && value is num) {
          pricesUsd[date] = value.toDouble();
        }
      }

      final coveredFrom = DateTime.tryParse(
        (decoded['coveredFrom'] as String?) ?? '',
      );
      final coveredTo = DateTime.tryParse(
        (decoded['coveredTo'] as String?) ?? '',
      );
      final savedAt = DateTime.tryParse((decoded['savedAt'] as String?) ?? '');
      if (pricesUsd.isEmpty ||
          coveredFrom == null ||
          coveredTo == null ||
          savedAt == null) {
        return null;
      }

      return CryptoUsdHistorySnapshot(
        code: (decoded['code'] as String?) ?? code,
        coveredFrom: coveredFrom,
        coveredTo: coveredTo,
        savedAt: savedAt,
        pricesUsd: pricesUsd,
      );
    } catch (e) {
      debugPrint('Corrupt crypto history cache for $code dropped: $e');
      return null;
    }
  }

  Future<void> write(CryptoUsdHistorySnapshot snapshot) async {
    final key = _key(snapshot.code);
    final existing = await read(snapshot.code);
    final toSave = existing == null ? snapshot : existing.mergedWith(snapshot);

    await _preferences.setString(
      key,
      jsonEncode(<String, Object?>{
        'code': toSave.code,
        'coveredFrom': toSave.coveredFrom.toIso8601String(),
        'coveredTo': toSave.coveredTo.toIso8601String(),
        'savedAt': toSave.savedAt.toIso8601String(),
        'pricesUsd': toSave.pricesUsd.map(
          (date, price) => MapEntry(date.toIso8601String(), price),
        ),
      }),
    );
  }

  String _key(String code) => 'crypto_usd_history_$code';
}
