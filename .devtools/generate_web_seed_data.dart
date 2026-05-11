import 'dart:convert';

import 'sample_seed_data.dart';

void main(List<String> args) {
  final options = _parseArgs(args);
  final values = generateMockSharedPreferencesValues(
    days: options.days,
    today: options.today,
  );

  final storage = <String, String>{};
  for (final entry in values.entries) {
    storage['flutter.${entry.key}'] = jsonEncode(entry.value);
  }

  final payload = <String, Object>{
    'days': options.days,
    'today': options.today.toIso8601String(),
    'storage': storage,
  };

  print(const JsonEncoder.withIndent('  ').convert(payload));
}

({int days, DateTime today}) _parseArgs(List<String> args) {
  var days = 90;
  var today = DateTime.now();

  for (var i = 0; i < args.length; i += 1) {
    final arg = args[i];
    if (arg == '--days' && i + 1 < args.length) {
      days = int.tryParse(args[i + 1]) ?? days;
      i += 1;
      continue;
    }
    if (arg.startsWith('--days=')) {
      days = int.tryParse(arg.split('=').last) ?? days;
      continue;
    }
    if (arg == '--today' && i + 1 < args.length) {
      today = DateTime.tryParse(args[i + 1]) ?? today;
      i += 1;
      continue;
    }
    if (arg.startsWith('--today=')) {
      today = DateTime.tryParse(arg.split('=').last) ?? today;
    }
  }

  if (days < 1) {
    days = 1;
  }

  today = DateTime(today.year, today.month, today.day);
  return (days: days, today: today);
}
