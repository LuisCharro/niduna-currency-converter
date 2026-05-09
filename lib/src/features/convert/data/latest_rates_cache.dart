import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/latest_rates_snapshot.dart';

class LatestRatesCache {
  LatestRatesCache(this._preferences);

  final SharedPreferences _preferences;

  Future<LatestRatesSnapshot?> read(String base) async {
    final raw = _preferences.getString(_key(base));
    if (raw == null) {
      return null;
    }

    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final ratesJson = json['rates'];
    if (ratesJson is! Map<String, dynamic>) {
      return null;
    }

    final rates = <String, double>{};
    for (final entry in ratesJson.entries) {
      final value = entry.value;
      if (value is num) {
        rates[entry.key] = value.toDouble();
      }
    }

    final savedAt = DateTime.tryParse((json['savedAt'] as String?) ?? '');
    if (rates.isEmpty || savedAt == null) {
      return null;
    }

    return LatestRatesSnapshot(
      base: (json['base'] as String?) ?? base,
      date: DateTime.tryParse((json['date'] as String?) ?? ''),
      savedAt: savedAt,
      rates: rates,
    );
  }

  Future<void> write(LatestRatesSnapshot snapshot) async {
    _preferences.setString(
      _key(snapshot.base),
      jsonEncode(<String, Object?>{
        'base': snapshot.base,
        'date': snapshot.date?.toIso8601String(),
        'savedAt': snapshot.savedAt.toIso8601String(),
        'rates': snapshot.rates,
      }),
    );
  }

  String _key(String base) => 'latest_rates_$base';
}
