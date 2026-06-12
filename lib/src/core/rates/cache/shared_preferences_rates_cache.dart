import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/rates_snapshot.dart';
import '../rates_cache.dart';

class SharedPreferencesRatesCache implements RatesCache {
  SharedPreferencesRatesCache(this._preferences);
  final SharedPreferences _preferences;
  static const String _trackedKeys = 'rates_cache_keys';

  @override
  Future<RatesSnapshot?> readLatest(String base) async {
    final raw = _preferences.getString(_latestKey(base));
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
    final key = _latestKey(snapshot.base);
    _preferences.setString(
      key,
      jsonEncode(<String, Object?>{
        'base': snapshot.base,
        'date': snapshot.date?.toIso8601String(),
        'savedAt': snapshot.savedAt.toIso8601String(),
        'rates': snapshot.rates,
      }),
    );
    _trackKey(key);
  }

  @override
  Future<void> invalidateLatest(String base) async {
    final key = _latestKey(base);
    _preferences.remove(key);
    _untrackKey(key);
  }

  @override
  Future<HistoricalSnapshot?> readHistorical({
    required String base,
    required String quote,
  }) async {
    final raw = _preferences.getString(_historicalKey(base, quote));
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
      coveredFrom:
          DateTime.tryParse((decoded['coveredFrom'] as String?) ?? '') ??
          data.keys.reduce((a, b) => a.isBefore(b) ? a : b),
      coveredTo:
          DateTime.tryParse((decoded['coveredTo'] as String?) ?? '') ??
          data.keys.reduce((a, b) => a.isAfter(b) ? a : b),
      data: data,
      savedAt: savedAt,
    );
  }

  @override
  Future<void> writeHistorical(HistoricalSnapshot snapshot) async {
    final key = _historicalKey(snapshot.base, snapshot.quote);
    final existing = await readHistorical(
      base: snapshot.base,
      quote: snapshot.quote,
    );
    final toSave = existing == null ? snapshot : existing.mergedWith(snapshot);

    _preferences.setString(
      key,
      jsonEncode(<String, Object?>{
        'base': toSave.base,
        'quote': toSave.quote,
        'coveredFrom': toSave.coveredFrom.toIso8601String(),
        'coveredTo': toSave.coveredTo.toIso8601String(),
        'savedAt': toSave.savedAt.toIso8601String(),
        'data': toSave.data.map(
          (date, rate) => MapEntry(date.toIso8601String(), rate),
        ),
      }),
    );
    _trackKey(key);
  }

  @override
  Future<void> invalidateHistorical({
    required String base,
    required String quote,
  }) async {
    final key = _historicalKey(base, quote);
    _preferences.remove(key);
    _untrackKey(key);
  }

  @override
  Future<void> clear() async {
    final keys = _trackedCacheKeys();
    for (final key in keys) {
      _preferences.remove(key);
    }
    _preferences.remove(_trackedKeys);
  }

  String _latestKey(String base) => 'latest_rates_$base';

  String _historicalKey(String base, String quote) =>
      'historical_rates_${base}_$quote';

  List<String> _trackedCacheKeys() {
    final raw = _preferences.getString(_trackedKeys);
    if (raw == null) return <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (e) {
      debugPrint('Corrupt tracked cache keys, resetting: $e');
    }
    return <String>[];
  }

  void _trackKey(String key) {
    final keys = _trackedCacheKeys().toSet()..add(key);
    _preferences.setString(_trackedKeys, jsonEncode(keys.toList()));
  }

  void _untrackKey(String key) {
    final keys = _trackedCacheKeys().toSet()..remove(key);
    _preferences.setString(_trackedKeys, jsonEncode(keys.toList()));
  }

  Map<String, dynamic>? _decodeObject(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      debugPrint('Corrupt rates cache entry dropped: $e');
      return null;
    }
  }
}
