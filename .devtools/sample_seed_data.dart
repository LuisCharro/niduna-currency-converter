import 'dart:convert';

const seededProfileStorageKey = 'flutter.currencyConverter.profile';
const seededLogsStorageKey = 'flutter.currencyConverter.logs';
const seededTemplatesStorageKey = 'flutter.currencyConverter.templates';

Map<String, Object> generateMockSharedPreferencesValues({
  required int days,
  DateTime? today,
}) {
  final dataset = buildSampleSeedDataset(days: days, today: today);
  return <String, Object>{
    seededProfileStorageKey: dataset.profileJson,
    seededLogsStorageKey: dataset.logsJson,
    seededTemplatesStorageKey: dataset.templatesJson,
  };
}

Map<String, Object> generateOnboardedProfileOnlyMockSharedPreferencesValues() {
  final profile = <String, dynamic>{
    'onboardingComplete': true,
  };

  return <String, Object>{
    seededProfileStorageKey: jsonEncode(profile),
    seededLogsStorageKey: jsonEncode(<String, dynamic>{}),
    seededTemplatesStorageKey: jsonEncode(<Object>[]),
  };
}

String generateAndroidSharedPrefsXml({required int days, DateTime? today}) {
  final dataset = buildSampleSeedDataset(days: days, today: today);
  final xml = StringBuffer()
    ..writeln("<?xml version='1.0' encoding='utf-8' standalone='yes' ?>")
    ..writeln('<map>')
    ..writeln(
      '    <string name="flutter.$seededLogsStorageKey">${_xmlEscape(dataset.logsJson)}</string>',
    )
    ..writeln(
      '    <string name="flutter.$seededProfileStorageKey">${_xmlEscape(dataset.profileJson)}</string>',
    )
    ..writeln(
      '    <string name="flutter.$seededTemplatesStorageKey">${_xmlEscape(dataset.templatesJson)}</string>',
    )
    ..writeln('</map>');
  return xml.toString();
}

String generateIosPrefsPlist({required int days, DateTime? today}) {
  final dataset = buildSampleSeedDataset(days: days, today: today);
  final plist = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    )
    ..writeln('<plist version="1.0">')
    ..writeln('<dict>')
    ..writeln('  <key>flutter.$seededLogsStorageKey</key>')
    ..writeln('  <string>${_xmlEscape(dataset.logsJson)}</string>')
    ..writeln('  <key>flutter.$seededProfileStorageKey</key>')
    ..writeln('  <string>${_xmlEscape(dataset.profileJson)}</string>')
    ..writeln('  <key>flutter.$seededTemplatesStorageKey</key>')
    ..writeln('  <string>${_xmlEscape(dataset.templatesJson)}</string>')
    ..writeln('</dict>')
    ..writeln('</plist>');
  return plist.toString();
}

SampleSeedDataset buildSampleSeedDataset({required int days, DateTime? today}) {
  final resolvedDays = days < 1 ? 1 : days;
  final normalizedToday = _normalizeDate(today ?? DateTime.now());

  final profile = <String, dynamic>{
    'onboardingComplete': true,
  };

  final logs = <String, dynamic>{};
  for (var daysAgo = resolvedDays - 1; daysAgo >= 0; daysAgo -= 1) {
    final date = normalizedToday.subtract(Duration(days: daysAgo));
    final dateKey = _dateKey(date);

    logs[dateKey] = {
      'dateKey': dateKey,
    };
  }

  return SampleSeedDataset(
    profileJson: jsonEncode(profile),
    logsJson: jsonEncode(logs),
    templatesJson: jsonEncode(<Object>[]),
  );
}

class SampleSeedDataset {
  const SampleSeedDataset({
    required this.profileJson,
    required this.logsJson,
    required this.templatesJson,
  });

  final String profileJson;
  final String logsJson;
  final String templatesJson;
}

DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String _dateKey(DateTime date) {
  final normalized = _normalizeDate(date);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _xmlEscape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
