import 'sample_seed_data.dart';

void main(List<String> args) {
  final options = _parseArgs(args);

  switch (options.format) {
    case _OutputFormat.androidSharedPrefs:
      print(
        generateAndroidSharedPrefsXml(days: options.days, today: options.today),
      );
    case _OutputFormat.iosPlist:
      print(generateIosPrefsPlist(days: options.days, today: options.today));
  }
}

enum _OutputFormat { androidSharedPrefs, iosPlist }

({int days, DateTime today, _OutputFormat format}) _parseArgs(
  List<String> args,
) {
  var days = 30;
  var today = DateTime.now();
  var format = _OutputFormat.androidSharedPrefs;

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
      continue;
    }
    if (arg == '--format' && i + 1 < args.length) {
      format = _parseFormat(args[i + 1]) ?? format;
      i += 1;
      continue;
    }
    if (arg.startsWith('--format=')) {
      format = _parseFormat(arg.split('=').last) ?? format;
    }
  }

  if (days < 1) {
    days = 1;
  }

  today = DateTime(today.year, today.month, today.day);

  return (days: days, today: today, format: format);
}

_OutputFormat? _parseFormat(String raw) {
  return switch (raw) {
    'android' => _OutputFormat.androidSharedPrefs,
    'android-shared-prefs' => _OutputFormat.androidSharedPrefs,
    'ios' => _OutputFormat.iosPlist,
    'ios-plist' => _OutputFormat.iosPlist,
    _ => null,
  };
}
