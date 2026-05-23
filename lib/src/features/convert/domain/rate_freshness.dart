import 'package:intl/intl.dart';

class RateFreshness {
  RateFreshness._();

  static const int _centralEuropeUpdateHour = 16;

  static String updatedLabel({
    required DateTime? rateDate,
    required DateTime savedAt,
  }) {
    final locale = _localeCode();
    if (rateDate != null) {
      final formatted = _formatDate(rateDate, locale);
      return switch (locale) {
        'es' => 'Actualizado $formatted',
        'de' => 'Aktualisiert $formatted',
        'it' => 'Aggiornato $formatted',
        'fr' => 'Mis à jour $formatted',
        _ => 'Updated $formatted',
      };
    }
    final formatted = '${_formatDate(savedAt.toLocal(), locale)}, '
        '${_formatTime(savedAt.toLocal(), locale)}';
    return switch (locale) {
      'es' => 'Actualizado $formatted',
      'de' => 'Aktualisiert $formatted',
      'it' => 'Aggiornato $formatted',
      'fr' => 'Mis à jour $formatted',
      _ => 'Updated $formatted',
    };
  }

  static String nextUpdateLabel({DateTime? now}) {
    final update = nextExpectedUpdate(now: now);
    final locale = _localeCode();
    final formatted = _formatTime(update, locale);
    return switch (locale) {
      'es' => 'Próxima actualización aprox. a las $formatted hora local',
      'de' => 'Nächste Aktualisierung etwa um $formatted Ortszeit',
      'it' => 'Prossimo aggiornamento verso le $formatted ora locale',
      'fr' => 'Prochaine mise à jour vers $formatted heure locale',
      _ => 'Next around $formatted local',
    };
  }

  static DateTime nextExpectedUpdate({DateTime? now}) {
    final current = now ?? DateTime.now();
    final utcNow = current.toUtc();
    var centralEuropeDate = _centralEuropeDateFor(utcNow);

    while (true) {
      if (_isWeekend(centralEuropeDate)) {
        centralEuropeDate = centralEuropeDate.add(const Duration(days: 1));
        continue;
      }

      final updateUtc = _centralEuropeUpdateUtc(centralEuropeDate);
      if (utcNow.isBefore(updateUtc)) {
        return updateUtc.toLocal();
      }
      centralEuropeDate = centralEuropeDate.add(const Duration(days: 1));
    }
  }

  static DateTime _centralEuropeDateFor(DateTime utcNow) {
    final offset = _centralEuropeOffsetHours(utcNow);
    final centralEuropeNow = utcNow.add(Duration(hours: offset));
    return DateTime.utc(
      centralEuropeNow.year,
      centralEuropeNow.month,
      centralEuropeNow.day,
    );
  }

  static DateTime _centralEuropeUpdateUtc(DateTime centralEuropeDate) {
    final offset = _centralEuropeOffsetHours(
      DateTime.utc(
        centralEuropeDate.year,
        centralEuropeDate.month,
        centralEuropeDate.day,
        12,
      ),
    );
    return DateTime.utc(
      centralEuropeDate.year,
      centralEuropeDate.month,
      centralEuropeDate.day,
      _centralEuropeUpdateHour - offset,
    );
  }

  static int _centralEuropeOffsetHours(DateTime utc) {
    final starts = _lastSundayOfMonth(utc.year, DateTime.march);
    final ends = _lastSundayOfMonth(utc.year, DateTime.october);
    final dstStart = DateTime.utc(utc.year, DateTime.march, starts.day, 1);
    final dstEnd = DateTime.utc(utc.year, DateTime.october, ends.day, 1);
    return !utc.isBefore(dstStart) && utc.isBefore(dstEnd) ? 2 : 1;
  }

  static DateTime _lastSundayOfMonth(int year, int month) {
    final nextMonth = month == DateTime.december
        ? DateTime.utc(year + 1, DateTime.january)
        : DateTime.utc(year, month + 1);
    var day = nextMonth.subtract(const Duration(days: 1));
    while (day.weekday != DateTime.sunday) {
      day = day.subtract(const Duration(days: 1));
    }
    return day;
  }

  static bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  static String _localeCode() {
    final locale = Intl.getCurrentLocale();
    if (locale.isEmpty || locale == 'C') return 'en';
    return locale.split('_').first;
  }

  static String _formatDate(DateTime date, String locale) {
    final month = _monthLabel(date.month, locale);
    return locale == 'en' ? '$month ${date.day}' : '${date.day} $month';
  }

  static String _formatTime(DateTime date, String locale) {
    if (locale == 'en') {
      return DateFormat('h:mm a').format(date);
    }

    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String _monthLabel(int month, String locale) {
    const en = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const es = <String>[
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sept', 'oct', 'nov', 'dic',
    ];
    const de = <String>[
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
    ];
    const it = <String>[
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic',
    ];
    const fr = <String>[
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];

    final labels = switch (locale) {
      'es' => es,
      'de' => de,
      'it' => it,
      'fr' => fr,
      _ => en,
    };
    return labels[month - 1];
  }
}
