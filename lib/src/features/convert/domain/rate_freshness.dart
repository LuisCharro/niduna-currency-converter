import 'package:intl/intl.dart';

class RateFreshness {
  RateFreshness._();

  static String updatedLabel({
    required DateTime? rateDate,
    required DateTime savedAt,
  }) {
    final locale = _localeCode();
    if (rateDate != null) {
      final formatted = _formatDate(rateDate, locale);
      return switch (locale) {
        'es' => 'Tipos del $formatted',
        'de' => 'Kurse vom $formatted',
        'it' => 'Tassi del $formatted',
        'fr' => 'Taux du $formatted',
        _ => 'Rates from $formatted',
      };
    }
    final formatted =
        '${_formatDate(savedAt.toLocal(), locale)}, '
        '${_formatTime(savedAt.toLocal(), locale)}';
    return switch (locale) {
      'es' => 'Actualizado $formatted',
      'de' => 'Aktualisiert $formatted',
      'it' => 'Aggiornato $formatted',
      'fr' => 'Mis à jour $formatted',
      _ => 'Updated $formatted',
    };
  }

  static String nextUpdateLabel() {
    final locale = _localeCode();
    return switch (locale) {
      'es' =>
        'Comprobación automática la primera vez que abras la app cada día',
      'de' => 'Automatische Prüfung beim ersten Öffnen der App jeden Tag',
      'it' => "Controllo automatico alla prima apertura dell'app ogni giorno",
      'fr' =>
        "Vérification automatique à la première ouverture de l’app chaque jour",
      _ => 'Checks automatically the first time you open the app each day',
    };
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const es = <String>[
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sept',
      'oct',
      'nov',
      'dic',
    ];
    const de = <String>[
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    const it = <String>[
      'gen',
      'feb',
      'mar',
      'apr',
      'mag',
      'giu',
      'lug',
      'ago',
      'set',
      'ott',
      'nov',
      'dic',
    ];
    const fr = <String>[
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
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
