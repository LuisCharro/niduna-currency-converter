import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../currency/currency_code_migration.dart';
import '../currency/supported_currencies.dart';
import 'models/temporary_unlock.dart';

class TemporaryUnlockStore {
  TemporaryUnlockStore(this._preferences);

  static const String _registryKey = 'temp_unlocks_registry';

  final SharedPreferences _preferences;

  Future<void> save(TemporaryUnlock unlock) async {
    final canonical = _canonicalUnlock(unlock);
    if (canonical == null) return;
    final registry = await _loadRegistry();
    registry[canonical.storageKey] = canonical.toJson();
    await _saveRegistry(registry);
  }

  Future<TemporaryUnlock?> load(String base, String quote) async {
    final canonicalBase = canonicalCurrencyCode(base);
    final canonicalQuote = canonicalCurrencyCode(quote);
    final registry = await _loadRegistry();
    final key =
        'temp_unlock_${TemporaryUnlock.canonicalKey(canonicalBase, canonicalQuote)}';
    final raw = registry[key];
    if (raw is! Map) return null;
    try {
      final unlock = TemporaryUnlock.fromJson(raw.cast<String, dynamic>());
      return unlock.isExpired ? null : unlock;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String base, String quote) async {
    final registry = await _loadRegistry();
    final key =
        'temp_unlock_${TemporaryUnlock.canonicalKey(canonicalCurrencyCode(base), canonicalCurrencyCode(quote))}';
    if (registry.remove(key) != null) await _saveRegistry(registry);
  }

  Future<void> clearAll() => _preferences.remove(_registryKey);

  /// Converts the invalid nested-string format written by `1.0.0+4` to valid
  /// JSON and maps legacy MATIC pairs to POL. The rewrite is idempotent and
  /// preserves every decodable, supported, unexpired unlock.
  Future<void> migrateIfNeeded() async {
    final raw = _preferences.getString(_registryKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = _decodeRegistry(raw);
    if (decoded == null) return;

    final migrated = <String, dynamic>{};
    for (final value in decoded.values) {
      if (value is! Map) continue;
      try {
        final unlock = TemporaryUnlock.fromJson(value.cast<String, dynamic>());
        final canonical = _canonicalUnlock(unlock);
        if (canonical != null && !canonical.isExpired) {
          migrated[canonical.storageKey] = canonical.toJson();
        }
      } catch (_) {
        // Ignore only the malformed entry; other unlocks remain recoverable.
      }
    }

    final encoded = jsonEncode(migrated);
    if (encoded != raw) await _preferences.setString(_registryKey, encoded);
  }

  Future<void> cleanExpired() async {
    final registry = await _loadRegistry();
    final active = <String, dynamic>{};
    for (final value in registry.values) {
      if (value is! Map) continue;
      try {
        final unlock = TemporaryUnlock.fromJson(value.cast<String, dynamic>());
        final canonical = _canonicalUnlock(unlock);
        if (canonical != null && !canonical.isExpired) {
          active[canonical.storageKey] = canonical.toJson();
        }
      } catch (_) {
        // Malformed entries are omitted from the rewritten registry.
      }
    }
    await _saveRegistry(active);
  }

  Future<Map<String, dynamic>> _loadRegistry() async {
    final raw = _preferences.getString(_registryKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    return _decodeRegistry(raw) ?? <String, dynamic>{};
  }

  Future<void> _saveRegistry(Map<String, dynamic> registry) =>
      _preferences.setString(_registryKey, jsonEncode(registry));

  Map<String, dynamic>? _decodeRegistry(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {
      return _decodeLegacyRegistry(raw);
    }
    return null;
  }

  Map<String, dynamic>? _decodeLegacyRegistry(String raw) {
    final entries = <String, dynamic>{};
    final entryPattern = RegExp(
      r'"(temp_unlock_[A-Za-z0-9]+_[A-Za-z0-9]+)"\s*:\s*"\{([^}]*)\}"',
    );
    final fieldPattern = RegExp(r'"([A-Za-z]+)"\s*:\s*"([^"]*)"');

    for (final entryMatch in entryPattern.allMatches(raw)) {
      final body = entryMatch.group(2);
      if (body == null) continue;
      final fields = <String, dynamic>{};
      for (final fieldMatch in fieldPattern.allMatches(body)) {
        final key = fieldMatch.group(1);
        final value = fieldMatch.group(2);
        if (key == null || value == null) continue;
        fields[key] = key == 'durationMs' ? int.tryParse(value) : value;
      }
      if (fields.length == 4 && fields['durationMs'] != null) {
        entries[entryMatch.group(1)!] = fields;
      }
    }

    return entries.isEmpty ? null : entries;
  }

  static TemporaryUnlock? _canonicalUnlock(TemporaryUnlock unlock) {
    final base = canonicalCurrencyCode(unlock.base);
    final quote = canonicalCurrencyCode(unlock.quote);
    if (base == quote ||
        !isSupportedCurrencyCode(base) ||
        !isSupportedCurrencyCode(quote)) {
      return null;
    }
    return TemporaryUnlock(
      base: base,
      quote: quote,
      grantedAt: unlock.grantedAt,
      duration: unlock.duration,
    );
  }
}
