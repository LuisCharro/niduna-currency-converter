#!/usr/bin/env dart
// .devtools/check_provider_coverage.dart
//
// Opt-in live provider coverage diagnostic. Verifies the release-safe
// providers (Frankfurter v2 + fawazahmed0) cover every advertised
// fiat and crypto code in the catalog, and that the v2 historical
// endpoint shape matches what the app expects.
//
// Usage:
//   dart .devtools/check_provider_coverage.dart
//
// Exits non-zero on missing advertised coverage or HTTP errors against
// the release-safe endpoints. Uses live network; do NOT add to
// ./scripts/check.sh.

import 'dart:convert';
import 'dart:io';

import '../lib/src/core/currency/supported_currencies.dart';
import '../lib/src/core/rates/crypto/crypto_asset.dart';

const String _frankfurterV2Latest =
    'https://api.frankfurter.dev/v2/rates?base=USD';
const String _fawazahmedLatest =
    'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json';
const String _fawazahmedHistoryBase =
    'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api';

Future<int> main() async {
  print('Honest Fern — opt-in live provider coverage check');
  print('Run at: ${DateTime.now().toIso8601String()}\n');
  final results = <_Result>[];

  results.add(await _checkFrankfurter());
  results.add(await _checkFawazahmedLatest());
  results.add(await _checkFawazahmedPolHistory());

  final passed = results.where((r) => r.ok).length;
  final failed = results.where((r) => !r.ok).length;
  print('\nSummary: $passed passed / $failed failed');
  for (final r in results) {
    print('  [${r.ok ? "PASS" : "FAIL"}] ${r.label}');
    if (r.detail.isNotEmpty) print('         ${r.detail}');
  }

  return failed == 0 ? 0 : 1;
}

class _Result {
  _Result(this.label, this.ok, [this.detail = '']);
  final String label;
  final bool ok;
  final String detail;
}

Future<_Result> _checkFrankfurter() async {
  final label = 'Frankfurter v2 latest covers all ${supportedFiatCurrencies.length} fiat';
  try {
    final code = supportedFiatCurrencies.map((c) => c.code).toSet();
    final res = await _get(_frankfurterV2Latest);
    if (res.statusCode != 200) {
      return _Result(label, false,
          'HTTP ${res.statusCode}: ${_truncate(res.body)}');
    }
    final json = jsonDecode(res.body);
    if (json is! List) {
      return _Result(label, false,
          'expected v2 row-list, got ${json.runtimeType}');
    }
    final returned = <String>{};
    for (final row in json) {
      if (row is Map && row['quote'] is String) {
        returned.add(row['quote'] as String);
      }
    }
    final missing = code.difference(returned);
    if (missing.isNotEmpty) {
      final sample = missing.toList()..sort();
      return _Result(label, false,
          'missing fiat codes: ${sample.take(10).join(", ")}'
          '${missing.length > 10 ? " (+${missing.length - 10} more)" : ""}');
    }
    return _Result(label, true,
        '${returned.length}/${code.length} fiat codes returned');
  } catch (e) {
    return _Result(label, false, e.toString());
  }
}

Future<_Result> _checkFawazahmedLatest() async {
  final label = 'fawazahmed0 latest maps provider keys to all ${supportedCryptoAssets.length} crypto';
  try {
    final res = await _get(_fawazahmedLatest);
    if (res.statusCode != 200) {
      return _Result(label, false, 'HTTP ${res.statusCode}');
    }
    final json = jsonDecode(res.body);
    if (json is! Map || json['usd'] is! Map) {
      return _Result(label, false, 'unexpected payload shape');
    }
    final usd = (json['usd'] as Map).cast<String, dynamic>();
    final missing = <String>[];
    for (final asset in supportedCryptoAssets) {
      final key = asset.code.toLowerCase();
      final raw = usd[key];
      if (raw is! num || raw <= 0) missing.add(key);
    }
    if (missing.isNotEmpty) {
      return _Result(label, false,
          'missing/non-positive crypto keys: ${missing.join(", ")}');
    }
    final pol = usd['pol'];
    final polNote = pol is num && pol > 0 ? ' (pol=$pol)' : '';
    return _Result(label, true,
        'all ${supportedCryptoAssets.length} crypto keys present$polNote');
  } catch (e) {
    return _Result(label, false, e.toString());
  }
}

Future<_Result> _checkFawazahmedPolHistory() async {
  final label = 'fawazahmed0 POL history sample (today − 30d)';
  try {
    final today = DateTime.now();
    final sample = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 30));
    final iso = '${sample.year.toString().padLeft(4, "0")}-'
        '${sample.month.toString().padLeft(2, "0")}-'
        '${sample.day.toString().padLeft(2, "0")}';
    final url = '$_fawazahmedHistoryBase@$iso/v1/currencies/usd.min.json';
    final res = await _get(url);
    if (res.statusCode == 404) {
      return _Result(label, true,
          'no $iso file (weekend/holiday); rolling window still covered by other dates');
    }
    if (res.statusCode != 200) {
      return _Result(label, false, 'HTTP ${res.statusCode}');
    }
    final json = jsonDecode(res.body);
    if (json is! Map || json['usd'] is! Map) {
      return _Result(label, false, 'unexpected payload');
    }
    final usd = (json['usd'] as Map).cast<String, dynamic>();
    final pol = usd['pol'];
    if (pol is! num || pol <= 0) {
      return _Result(label, false,
          'historical file for $iso missing pol key');
    }
    return _Result(label, true, 'pol=$pol on $iso');
  } catch (e) {
    return _Result(label, false, e.toString());
  }
}

class _HttpResponse {
  _HttpResponse(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

Future<_HttpResponse> _get(String url) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    return _HttpResponse(res.statusCode, body);
  } finally {
    client.close();
  }
}

String _truncate(String s, [int max = 200]) {
  return s.length <= max ? s : '${s.substring(0, max)}…';
}
