part of 'ui_copy.dart';

List<String> cryptoDataLines(BuildContext context, bool enabled) {
  return switch (_lang(context)) {
    'es' => <String>[
      enabled
          ? 'Los gráficos cripto muestran hasta 1 año de datos diarios.'
          : 'Los gráficos cripto no están disponibles en esta compilación.',
      if (enabled)
        'En gráficos mixtos, los tipos fiat pueden quedar en el último cierre disponible durante fines de semana y festivos.',
    ],
    'de' => <String>[
      enabled
          ? 'Krypto-Charts zeigen bis zu 1 Jahr tägliche Daten.'
          : 'Krypto-Charts sind in diesem Build nicht verfügbar.',
      if (enabled)
        'In gemischten Charts können Fiat-Kurse am Wochenende und an Feiertagen beim letzten verfügbaren Schlusskurs bleiben.',
    ],
    'it' => <String>[
      enabled
          ? 'I grafici crypto mostrano fino a 1 anno di dati giornalieri.'
          : 'I grafici crypto non sono disponibili in questa build.',
      if (enabled)
        "Nei grafici misti, i tassi fiat possono restare all'ultima chiusura disponibile nei fine settimana e festivi.",
    ],
    'fr' => <String>[
      enabled
          ? 'Les graphiques crypto affichent jusqu’à 1 an de données quotidiennes.'
          : 'Les graphiques crypto ne sont pas disponibles dans cette build.',
      if (enabled)
        'Dans les graphiques mixtes, les taux fiat peuvent rester à la dernière clôture disponible le week-end et les jours fériés.',
    ],
    _ => <String>[
      enabled
          ? 'Crypto charts show up to 1 year of daily data.'
          : 'Crypto charts are not available in this build.',
      if (enabled)
        'In mixed charts, fiat rates may stay at the last available close on weekends and public holidays.',
    ],
  };
}
