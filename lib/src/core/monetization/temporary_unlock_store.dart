import 'package:shared_preferences/shared_preferences.dart';

import 'models/temporary_unlock.dart';

class TemporaryUnlockStore {
  TemporaryUnlockStore(this._preferences);
  final SharedPreferences _preferences;

  static const String _registryKey = 'temp_unlocks_registry';

  Future<void> save(TemporaryUnlock unlock) async {
    final registry = await _loadRegistry();
    registry[unlock.storageKey] = unlock.toJson();
    await _saveRegistry(registry);
  }

  Future<TemporaryUnlock?> load(String base, String quote) async {
    final registry = await _loadRegistry();
    final raw = registry[TemporaryUnlock.canonicalKey(base, quote)];
    if (raw == null) return null;
    final unlock = TemporaryUnlock.fromJson(raw as Map<String, dynamic>);
    return unlock.isExpired ? null : unlock;
  }

  Future<Map<String, dynamic>> _loadRegistry() async {
    final raw = _preferences.getString(_registryKey);
    if (raw == null || raw.isEmpty) return {};
    return _decodeMap(raw);
  }

  Future<void> _saveRegistry(Map<String, dynamic> registry) async {
    await _preferences.setString(_registryKey, _encodeRegistry(registry));
  }

  Future<void> remove(String base, String quote) async {
    final registry = await _loadRegistry();
    registry.remove(TemporaryUnlock.canonicalKey(base, quote));
    await _saveRegistry(registry);
  }

  Future<void> clearAll() async {
    final keys = (await _loadRegistry()).keys.toList();
    for (final key in keys) {
      await _preferences.remove('temp_unlock_$key');
    }
    await _preferences.remove(_registryKey);
  }

  /// One-shot migration that rewrites legacy `MATIC` entries in the
  /// registry to `POL`. Idempotent: a second call after the first must
  /// leave the stored representation byte-equivalent (for non-MATIC entries).
  ///
  /// The shipped 1.0.0+4 registry format has overlapping quote marks between
  /// outer registry and inner unlock JSON; the legacy `_parseJson` returns
  /// an empty Map for it. Per plan §C4, when the format cannot be safely
  /// decoded, MATIC entries are removed (not migrated to POL); unrelated
  /// entries are left byte-equivalent.
  Future<void> migrateIfNeeded() async {
    final raw = _preferences.getString(_registryKey);
    if (raw == null || raw.isEmpty) return;
    if (!raw.contains('MATIC')) return;

    // Step 1 — strip middle / last MATIC entries (preceded by `, `).
    final midPattern = RegExp(
      r',\s*"temp_unlock_(?:[A-Z]+_MATIC|MATIC_[A-Z]+)":\s*"\{[^}]*\}"[,\s]*',
    );
    var cleaned = raw.replaceAll(midPattern, '');

    // Step 2 — strip the first MATIC entry if it survived step 1.
    if (cleaned.contains(RegExp(
      r'temp_unlock_(?:[A-Z]+_MATIC|MATIC_[A-Z]+)',
    ))) {
      cleaned = cleaned.replaceFirst(
        RegExp(
          r'\{\s*"temp_unlock_(?:[A-Z]+_MATIC|MATIC_[A-Z]+)":\s*"\{[^}]*\}"[,\s]*',
        ),
        '{',
      );
    }

    if (cleaned != raw) {
      await _preferences.setString(_registryKey, cleaned);
    }
  }

  Future<void> cleanExpired() async {
    final registry = await _loadRegistry();
    final expired = <String>[];
    for (final entry in registry.entries) {
      final raw = entry.value;
      if (raw is! Map<String, dynamic>) continue;
      try {
        final unlock = TemporaryUnlock.fromJson(raw);
        if (unlock.isExpired) expired.add(entry.key);
      } catch (_) {}
    }
    for (final key in expired) {
      registry.remove(key);
      await _preferences.remove(key);
    }
    if (expired.isNotEmpty) await _saveRegistry(registry);
  }

  String _encodeRegistry(Map<String, dynamic> data) {
    final parts = data.entries.map((e) {
      final v = e.value is String ? e.value : _valueToString(e.value);
      return '"${e.key}": "$v"';
    });
    return '{${parts.join(', ')}}';
  }

  String _valueToString(dynamic value) {
    if (value is Map) return _encodeRegistry(value.cast<String, dynamic>());
    if (value is List) return '[${value.join(', ')}]';
    return value.toString();
  }

  Map<String, dynamic> _decodeMap(String raw) {
    try {
      return _parseJson(raw);
    } catch (_) {}
    return {};
  }

  Map<String, dynamic> _parseJson(String source) {
    final result = <String, dynamic>{};
    var i = 0;
    while (i < source.length) {
      if (source[i] == '{') {
        i++;
        while (i < source.length && source[i] != '}') {
          final keyStart = source.indexOf("':", i);
          if (keyStart == -1 || keyStart >= source.length) {
            break;
          }
          final key = source
              .substring(i, keyStart)
              .trim()
              .replaceAll('"', '')
              .trim();
          i = keyStart + 2;
          if (i >= source.length) {
            break;
          }
          final valStart = source.indexOf(':', i);
          if (valStart == -1 || valStart >= source.length) {
            break;
          }
          i = valStart + 1;
          while (i < source.length && source[i] == ' ') {
            i++;
          }
          if (i >= source.length) {
            break;
          }
          final commaIdx = source.indexOf(',', i);
          final braceIdx = source.indexOf('}', i);
          var valEnd = commaIdx;
          if (valEnd == -1 || (braceIdx >= 0 && braceIdx < valEnd)) {
            valEnd = braceIdx;
          }
          if (valEnd == -1) {
            valEnd = source.length;
          }
          result[key] = source
              .substring(i, valEnd)
              .trim()
              .replaceAll('"', '')
              .trim();
          i = valEnd + 1;
        }
      } else {
        i++;
      }
    }
    return result;
  }
}
