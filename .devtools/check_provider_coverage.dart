#!/usr/bin/env dart
// ignore_for_file: avoid_print

// Opt-in live diagnostic for the release-safe provider contract.
//
// Usage: dart .devtools/check_provider_coverage.dart
//
// This intentionally uses live network data. Do not add it to scripts/check.sh.

import 'dart:convert';
import 'dart:io';

import 'package:currency_converter/src/core/currency/supported_currencies.dart';
import 'package:currency_converter/src/core/rates/crypto/crypto_asset.dart';

const String _frankfurterHost = 'api.frankfurter.dev';
const List<String> _fawazahmedLatestUrls = <String>[
  'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
  'https://latest.currency-api.pages.dev/v1/currencies/usd.json',
];

Future<int> main() async {
  print('Honest Fern — opt-in live provider coverage check');
  print('Run at: ${DateTime.now().toIso8601String()}\n');

  final results = <_Result>[
    await _checkFrankfurterLatest(),
    await _checkFrankfurterHistory(),
    await _checkFawazahmedLatest(),
    await _checkFawazahmedPolHistory(daysAgo: 30),
    await _checkFawazahmedPolHistory(daysAgo: 365),
  ];

  final failed = results.where((result) => !result.ok).length;
  print('\nSummary: ${results.length - failed} passed / $failed failed');
  for (final result in results) {
    print('  [${result.ok ? 'PASS' : 'FAIL'}] ${result.label}');
    if (result.detail.isNotEmpty) print('         ${result.detail}');
  }
  return failed == 0 ? 0 : 1;
}

Future<_Result> _checkFrankfurterLatest() async {
  final expected = supportedFiatCurrencies
      .map((currency) => currency.code)
      .toSet();
  const base = 'USD';
  final uri = Uri.https(_frankfurterHost, '/v2/rates', <String, String>{
    'base': base,
  });
  final label =
      'Frankfurter v2 latest covers all ${supportedFiatCurrencies.length} fiat';

  try {
    final response = await _get(uri);
    if (response.statusCode != 200) {
      return _Result(
        label,
        false,
        'HTTP ${response.statusCode}: ${_truncate(response.body)}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return _Result(
        label,
        false,
        'expected v2 row-list, got ${decoded.runtimeType}',
      );
    }

    final returned = <String>{base};
    final invalid = <String>[];
    for (final row in decoded) {
      if (row is! Map) continue;
      final quote = row['quote'];
      if (quote is! String || !expected.contains(quote)) continue;
      final rowBase = row['base'];
      final rate = row['rate'];
      final date = DateTime.tryParse('${row['date']}');
      if (rowBase != base || rate is! num || rate <= 0 || date == null) {
        invalid.add('$rowBase/$quote/${row['date']}/$rate');
        continue;
      }
      returned.add(quote);
    }

    final missing = expected.difference(returned).toList()..sort();
    if (missing.isNotEmpty || invalid.isNotEmpty) {
      return _Result(
        label,
        false,
        <String>[
          if (missing.isNotEmpty) 'missing: ${missing.join(', ')}',
          if (invalid.isNotEmpty) 'invalid rows: ${invalid.take(3).join('; ')}',
        ].join(' | '),
      );
    }
    return _Result(
      label,
      true,
      '${returned.length}/${expected.length} codes from the latest endpoint',
    );
  } catch (error) {
    return _Result(label, false, error.toString());
  }
}

Future<_Result> _checkFrankfurterHistory() async {
  final expected = supportedFiatCurrencies
      .map((currency) => currency.code)
      .toSet();
  const base = 'USD';
  final quotes = expected.where((code) => code != base).toList()..sort();
  final to = _dateOnly(DateTime.now());
  final from = to.subtract(const Duration(days: 14));
  final uri = Uri.https(_frankfurterHost, '/v2/rates', <String, String>{
    'from': _formatDate(from),
    'to': _formatDate(to),
    'base': base,
    'quotes': quotes.join(','),
  });
  final label =
      'Frankfurter v2 history covers all ${supportedFiatCurrencies.length} fiat';

  try {
    final response = await _get(uri);
    if (response.statusCode != 200) {
      return _Result(
        label,
        false,
        'HTTP ${response.statusCode}: ${_truncate(response.body)}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return _Result(
        label,
        false,
        'expected v2 row-list, got ${decoded.runtimeType}',
      );
    }

    final returned = <String>{base};
    final invalid = <String>[];
    for (final row in decoded) {
      if (row is! Map) {
        invalid.add('non-map row');
        continue;
      }
      final rowBase = row['base'];
      final quote = row['quote'];
      final rate = row['rate'];
      final date = DateTime.tryParse('${row['date']}');
      if (rowBase != base ||
          quote is! String ||
          !quotes.contains(quote) ||
          rate is! num ||
          rate <= 0 ||
          date == null) {
        invalid.add('$rowBase/$quote/${row['date']}/$rate');
        continue;
      }
      // Frankfurter may prepend the last known observation when `from` falls
      // on a non-publishing day. The app deliberately drops that carry-over;
      // coverage here must likewise come from a point inside the requested
      // interval.
      if (date.isBefore(from) || date.isAfter(to)) continue;
      returned.add(quote);
    }

    final missing = expected.difference(returned).toList()..sort();
    if (missing.isNotEmpty || invalid.isNotEmpty) {
      return _Result(
        label,
        false,
        <String>[
          if (missing.isNotEmpty) 'missing: ${missing.join(', ')}',
          if (invalid.isNotEmpty) 'invalid rows: ${invalid.take(3).join('; ')}',
        ].join(' | '),
      );
    }
    return _Result(
      label,
      true,
      '${returned.length}/${expected.length} codes; '
      '${_formatDate(from)}..${_formatDate(to)}',
    );
  } catch (error) {
    return _Result(label, false, error.toString());
  }
}

Future<_Result> _checkFawazahmedLatest() async {
  final label =
      'fawazahmed0 latest covers all ${supportedCryptoAssets.length} crypto';
  try {
    final response = await _getFirstSuccess(
      _fawazahmedLatestUrls.map(Uri.parse),
    );
    if (response.statusCode != 200) {
      return _Result(label, false, 'HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['usd'] is! Map) {
      return _Result(label, false, 'unexpected payload shape');
    }
    final usd = (decoded['usd'] as Map).cast<String, dynamic>();
    final missing = <String>[];
    for (final asset in supportedCryptoAssets) {
      final key = asset.code.toLowerCase();
      final raw = usd[key];
      if (raw is! num || raw <= 0) missing.add(key);
    }
    if (missing.isNotEmpty) {
      return _Result(
        label,
        false,
        'missing/non-positive keys: ${missing.join(', ')}',
      );
    }
    return _Result(label, true, 'all crypto keys present, including pol');
  } catch (error) {
    return _Result(label, false, error.toString());
  }
}

Future<_Result> _checkFawazahmedPolHistory({required int daysAgo}) async {
  final target = _dateOnly(DateTime.now()).subtract(Duration(days: daysAgo));
  final label = 'fawazahmed0 POL history near today − ${daysAgo}d';
  final attempts = <String>[];

  try {
    for (var offset = 0; offset < 7; offset++) {
      final date = target.subtract(Duration(days: offset));
      final iso = _formatDate(date);
      final urls = <Uri>[
        Uri.parse(
          'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$iso/v1/currencies/usd.min.json',
        ),
        Uri.parse(
          'https://$iso.currency-api.pages.dev/v1/currencies/usd.min.json',
        ),
      ];
      final response = await _getFirstSuccess(urls);
      attempts.add('$iso:${response.statusCode}');
      if (response.statusCode == 404) continue;
      if (response.statusCode != 200) continue;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['usd'] is! Map) continue;
      final pol = (decoded['usd'] as Map)['pol'];
      if (pol is num && pol > 0) {
        return _Result(label, true, 'pol=$pol on $iso');
      }
      return _Result(label, false, '$iso is missing a positive pol key');
    }
    return _Result(
      label,
      false,
      'no usable file in 7-day window: ${attempts.join(', ')}',
    );
  } catch (error) {
    return _Result(label, false, error.toString());
  }
}

Future<_HttpResponse> _getFirstSuccess(Iterable<Uri> urls) async {
  _HttpResponse? last;
  for (final url in urls) {
    try {
      final response = await _get(url);
      last = response;
      if (response.statusCode == 200) return response;
    } catch (_) {
      // Try the configured release-safe mirror before surfacing failure.
    }
  }
  return last ?? _HttpResponse(599, 'all provider endpoints failed');
}

Future<_HttpResponse> _get(Uri url) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client
        .getUrl(url)
        .timeout(const Duration(seconds: 15));
    final response = await request.close().timeout(const Duration(seconds: 15));
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 20));
    return _HttpResponse(response.statusCode, body);
  } finally {
    client.close(force: true);
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _truncate(String value, [int max = 200]) =>
    value.length <= max ? value : '${value.substring(0, max)}…';

class _HttpResponse {
  _HttpResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

class _Result {
  _Result(this.label, this.ok, [this.detail = '']);

  final String label;
  final bool ok;
  final String detail;
}
