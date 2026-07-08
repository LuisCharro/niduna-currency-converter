part of 'ui_copy.dart';

List<String> cryptoDataLines(BuildContext context, bool enabled) {
  return switch (_lang(context)) {
    'es' => <String>[
        'Los tipos de cripto siguen el mismo calendario diario de actualización que las divisas fiat.',
        enabled
            ? 'Los gráficos cripto muestran historial diario de hasta 1 año.'
            : 'Los gráficos cripto no están disponibles en esta compilación.',
        if (enabled)
          'En gráficos mixtos fiat/cripto, los valores fiat se mantienen en el último cierre disponible del mercado durante fines de semana y festivos.',
      ],
    'de' => <String>[
        'Krypto-Kurse folgen demselben täglichen Aktualisierungsplan wie Fiat-Kurse.',
        enabled
            ? 'Krypto-Charts zeigen tägliche Historie für bis zu 1 Jahr.'
            : 'Krypto-Charts sind in diesem Build nicht verfügbar.',
        if (enabled)
          'Bei gemischten Fiat-/Krypto-Charts bleiben Fiat-Werte an Wochenenden und Feiertagen auf dem letzten verfügbaren Marktschluss.',
      ],
    'it' => <String>[
        'I tassi delle crypto seguono lo stesso programma giornaliero di aggiornamento dei tassi fiat.',
        enabled
            ? 'I grafici crypto mostrano storico giornaliero fino a 1 anno.'
            : 'I grafici crypto non sono disponibili in questa build.',
        if (enabled)
          "Nei grafici misti fiat/crypto, i valori fiat restano sull'ultima chiusura di mercato disponibile durante fine settimana e festivi.",
      ],
    'fr' => <String>[
        'Les taux crypto suivent le même calendrier quotidien de mise à jour que les taux fiat.',
        enabled
            ? "Les graphiques crypto affichent un historique quotidien jusqu'à 1 an."
            : 'Les graphiques crypto ne sont pas disponibles dans cette build.',
        if (enabled)
          'Pour les graphiques mixtes fiat/crypto, les valeurs fiat restent sur la dernière clôture de marché disponible pendant les week-ends et jours fériés.',
      ],
    _ => <String>[
        'Crypto rates follow the same daily update schedule as fiat rates.',
        enabled
            ? 'Crypto charts show daily history for up to 1 year.'
            : 'Crypto charts are not available in this build.',
        if (enabled)
          'For mixed fiat and crypto charts, fiat values stay on the last available market close over weekends and holidays.',
      ],
  };
}
