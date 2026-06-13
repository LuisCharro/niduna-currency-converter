import 'sample_seed_data.dart';

void main(List<String> args) {
  final options = _parseArgs(args);

  final seedOptions = SampleSeedOptions(
    includeEntitlements: !options.freeUser,
    includeFavorites: !options.noFavorites,
  );

  switch (options.format) {
    case _OutputFormat.androidSharedPrefs:
      print(
        generateAndroidSharedPrefsXml(
          days: options.days,
          today: options.today,
          options: seedOptions,
        ),
      );
    case _OutputFormat.iosPlist:
      print(
        generateIosPrefsPlist(
          days: options.days,
          today: options.today,
          options: seedOptions,
        ),
      );
  }
}

enum _OutputFormat { androidSharedPrefs, iosPlist }

class _ParsedArgs {
  const _ParsedArgs({
    required this.days,
    required this.today,
    required this.format,
    required this.freeUser,
    required this.noFavorites,
  });

  final int days;
  final DateTime today;
  final _OutputFormat format;
  final bool freeUser;
  final bool noFavorites;
}

_ParsedArgs _parseArgs(List<String> args) {
  var days = 30;
  var today = DateTime.now();
  var format = _OutputFormat.androidSharedPrefs;
  var freeUser = false;
  var noFavorites = false;

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
      continue;
    }
    if (arg == '--free-user') {
      freeUser = true;
      continue;
    }
    if (arg == '--no-favorites') {
      noFavorites = true;
      continue;
    }
  }

  if (days < 1) {
    days = 1;
  }

  today = DateTime(today.year, today.month, today.day);

  return _ParsedArgs(
    days: days,
    today: today,
    format: format,
    freeUser: freeUser,
    noFavorites: noFavorites,
  );
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
