import 'dart:convert';

const _entitlementRemoveAdsKey = 'entitlement_remove_ads_lifetime';
const _entitlementChartsProKey = 'entitlement_charts_pro_lifetime';
const _favoritePairsKey = 'favorite_pairs';

const _favoritePairsValue = <String>['USD-BTC', 'USD-EUR', 'USD-MXN'];

class SampleSeedOptions {
  const SampleSeedOptions({
    this.includeEntitlements = true,
    this.includeFavorites = true,
  });

  final bool includeEntitlements;
  final bool includeFavorites;
}

String generateAndroidSharedPrefsXml({
  required int days,
  DateTime? today,
  SampleSeedOptions options = const SampleSeedOptions(),
}) {
  final buffer = StringBuffer()
    ..writeln("<?xml version='1.0' encoding='utf-8' standalone='yes' ?>")
    ..writeln('<map>');

  if (options.includeEntitlements) {
    buffer
      ..writeln(
        '    <boolean name="flutter.$_entitlementRemoveAdsKey" value="true" />',
      )
      ..writeln(
        '    <boolean name="flutter.$_entitlementChartsProKey" value="true" />',
      );
  }

  if (options.includeFavorites) {
    buffer.writeln(
      '    <string name="flutter.$_favoritePairsKey">'
      '${_xmlEscape(jsonEncode(_favoritePairsValue))}</string>',
    );
  }

  buffer.writeln('</map>');
  return buffer.toString();
}

String generateIosPrefsPlist({
  required int days,
  DateTime? today,
  SampleSeedOptions options = const SampleSeedOptions(),
}) {
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    )
    ..writeln('<plist version="1.0">')
    ..writeln('<dict>');

  if (options.includeEntitlements) {
    buffer
      ..writeln('  <key>$_entitlementRemoveAdsKey</key>')
      ..writeln('  <true/>')
      ..writeln('  <key>$_entitlementChartsProKey</key>')
      ..writeln('  <true/>');
  }

  if (options.includeFavorites) {
    buffer
      ..writeln('  <key>$_favoritePairsKey</key>')
      ..writeln(
        '  <string>${_xmlEscape(jsonEncode(_favoritePairsValue))}</string>',
      );
  }

  buffer
    ..writeln('</dict>')
    ..writeln('</plist>');
  return buffer.toString();
}

String _xmlEscape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
