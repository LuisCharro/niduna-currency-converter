import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/rates_snapshot.dart';
import '../rates_cache.dart';

class SharedPreferencesRatesCache implements RatesCache {
  SharedPreferencesRatesCache(this._preferences);
  final SharedPreferencesAsync _preferences;

  @override
  Future<RatesSnapshot?> readLatest(String base) async {
    final raw = await _preferences.getString(_latestKey(base));
    if (raw == null) return null;

    final json = _decodeObject(raw);
    if (json == null) return null;

    final ratesJson = json['rates'];
    if (ratesJson is! Map<String, dynamic>) return null;

    final rates = <String, double>{};
    for (final entry in ratesJson.entries) {
      final value = entry.value;
      if (value is num) {
        rates[entry.key] = value.toDouble();
      }
    }

    final savedAt = DateTime.tryParse((json['savedAt'] as String?) ?? '');
    if (rates.isEmpty || savedAt == null) return null;

    return RatesSnapshot(
      base: (json['base'] as String?) ?? base,
      date: DateTime.tryParse((json['date'] as String?) ?? ''),
      savedAt: savedAt,
      rates: rates,
    );
  }

  @override
  Future<void> writeLatest(RatesSnapshot snapshot) async {
    await _preferences.setString(
      _latestKey(snapshot.base),
      jsonEncode(<String, Object?>{
        'base': snapshot.base,
        'date': snapshot.date?.toIso8601String(),
        'savedAt': snapshot.savedAt.toIso8601String(),
        'rates': snapshot.rates,
      }),
    );
  }

  @override
  Future<void> invalidateLatest(String base) async {
    await _preferences.remove(_latestKey(base));
  }

  @override
  Future<HistoricalSnapshot?> readHistorical({
    required String base,
    required String quote,
    required String rangeKey,
  }) async {
    final raw = await _preferences.getString(
      _historicalKey(base, quote, rangeKey),
    );
    if (raw == null) return null;

    final decoded = _decodeObject(raw);
    if (decoded == null) return null;

    final dataJson = decoded['data'];
    if (dataJson is! Map<String, dynamic>) return null;

    final data = <DateTime, double>{};
    for (final entry in dataJson.entries) {
      final date = DateTime.tryParse(entry.key);
      final value = entry.value;
      if (date != null && value is num) {
        data[date] = value.toDouble();
      }
    }

    final savedAt = DateTime.tryParse((decoded['savedAt'] as String?) ?? '');
    if (data.isEmpty || savedAt == null) return null;

    return HistoricalSnapshot(
      base: (decoded['base'] as String?) ?? base,
      quote: (decoded['quote'] as String?) ?? quote,
      rangeKey: (decoded['rangeKey'] as String?) ?? rangeKey,
      data: data,
      savedAt: savedAt,
    );
  }

  @override
  Future<void> writeHistorical(HistoricalSnapshot snapshot) async {
    await _preferences.setString(
      _historicalKey(snapshot.base, snapshot.quote, snapshot.rangeKey),
      jsonEncode(<String, Object?>{
        'base': snapshot.base,
        'quote': snapshot.quote,
        'rangeKey': snapshot.rangeKey,
        'savedAt': snapshot.savedAt.toIso8601String(),
        'data': snapshot.data.map(
          (date, rate) => MapEntry(date.toIso8601String(), rate),
        ),
      }),
    );
  }

  @override
  Future<void> invalidateHistorical({
    required String base,
    required String quote,
    required String rangeKey,
  }) async {
    await _preferences.remove(_historicalKey(base, quote, rangeKey));
  }

  @override
  Future<void> clear() async {
    final keys = (await _preferences.getKeys())
        .where(
          (key) =>
              key.startsWith('latest_rates_') ||
              key.startsWith('historical_rates_'),
        )
        .toList();
    for (final key in keys) {
      await _preferences.remove(key);
    }
  }

  String _latestKey(String base) => 'latest_rates_$base';

  String _historicalKey(String base, String quote, String rangeKey) =>
      'historical_rates_${base}_${quote}_$rangeKey';

  Map<String, dynamic>? _decodeObject(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
