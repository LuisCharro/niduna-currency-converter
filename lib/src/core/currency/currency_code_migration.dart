/// Canonicalises a single currency code by mapping legacy aliases to their
/// current names. Pure function — no side effects, no validation.
String canonicalCurrencyCode(String raw) {
  final code = raw.trim().toUpperCase();
  if (code == 'MATIC') return 'POL';
  return code;
}

/// Canonicalises every code in [codes] and removes duplicates while
/// preserving the first-occurrence order.
List<String> canonicalizeCodeList(List<String> codes) {
  final seen = <String>{};
  final result = <String>[];
  for (final raw in codes) {
    final code = canonicalCurrencyCode(raw);
    if (seen.add(code)) result.add(code);
  }
  return result;
}

/// Canonicalises a favourite-pair key (formatted as `"BASE-QUOTE"`).
/// Returns `null` when the pair collapses to a same-currency pair, so the
/// caller can drop it. Invalid formats (more or fewer than two parts) are
/// returned unchanged so a separate validation layer can decide what to do.
String? canonicalizeFavoriteKey(String raw) {
  final parts = raw.split('-');
  if (parts.length != 2) return raw;
  final base = canonicalCurrencyCode(parts[0]);
  final quote = canonicalCurrencyCode(parts[1]);
  if (base == quote) return null;
  return '$base-$quote';
}

/// Canonicalises every favourite key and deduplicates, preserving first
/// occurrence. Drops same-currency pairs.
List<String> canonicalizeFavoriteKeys(List<String> rawKeys) {
  final seen = <String>{};
  final result = <String>[];
  for (final raw in rawKeys) {
    final key = canonicalizeFavoriteKey(raw);
    if (key == null) continue;
    if (seen.add(key)) result.add(key);
  }
  return result;
}
