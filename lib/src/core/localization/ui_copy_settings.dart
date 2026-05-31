part of 'ui_copy.dart';

String dataSourceFiatTitle(BuildContext context) => switch (_lang(context)) {
      'es' => 'Fiat actual y gráficos fiat',
      'de' => 'Aktuelle Fiat-Kurse und Fiat-Charts',
      'it' => 'Fiat attuale e grafici fiat',
      'fr' => 'Fiat actuel et graphiques fiat',
      _ => 'Fiat latest and fiat charts',
    };

String dataSourceFiatDetail(BuildContext context) => switch (_lang(context)) {
      'es' =>
        'Frankfurter proporciona los tipos fiat actuales e históricos usados por la app. Los gráficos fiat admiten rangos diarios de hasta 2 años.',
      'de' =>
        'Frankfurter liefert die aktuellen und historischen Fiat-Wechselkurse der App. Fiat-Charts unterstützen tägliche Bereiche bis zu 2 Jahren.',
      'it' =>
        "Frankfurter fornisce i tassi fiat attuali e storici usati dall'app. I grafici fiat supportano intervalli giornalieri fino a 2 anni.",
      'fr' =>
        "Frankfurter fournit les taux fiat actuels et historiques utilisés par l'app. Les graphiques fiat prennent en charge des plages quotidiennes jusqu'à 2 ans.",
      _ =>
        'Frankfurter provides the fiat latest and historical exchange rates used by the app. Fiat charts support daily ranges up to 2 years.',
    };

String dataSourceCryptoLatestTitle(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'Cripto actual',
      'de' => 'Aktuelle Krypto-Kurse',
      'it' => 'Crypto attuale',
      'fr' => 'Crypto actuel',
      _ => 'Crypto latest',
    };

String dataSourceCryptoLatestDetail(BuildContext context) =>
    switch (_lang(context)) {
      'es' =>
        'Los últimos precios de cripto usan la cadena activa de proveedor cripto de esta compilación. Los detalles del perfil de desarrollador solo se muestran dentro del Dev Sandbox.',
      'de' =>
        'Die neuesten Krypto-Preise verwenden die aktive Krypto-Anbieterkette dieses Builds. Details zum Entwicklerprofil werden nur in der Dev Sandbox angezeigt.',
      'it' =>
        'I prezzi più recenti delle crypto usano la catena di provider crypto attiva per questa build. I dettagli del profilo sviluppatore sono mostrati solo nel Dev Sandbox.',
      'fr' =>
        'Les derniers prix crypto utilisent la chaîne de fournisseurs crypto active pour cette build. Les détails du profil développeur ne sont affichés que dans le Dev Sandbox.',
      _ =>
        'Crypto latest prices use the active crypto provider chain for this build. Developer profile details are shown only inside the Dev Sandbox.',
    };

String dataSourceCryptoChartsTitle(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'Gráficos cripto',
      'de' => 'Krypto-Charts',
      'it' => 'Grafici crypto',
      'fr' => 'Graphiques crypto',
      _ => 'Crypto charts',
    };

String dataSourceCryptoChartsDetail(
        BuildContext context, String provider, bool enabled) =>
    switch (_lang(context)) {
      'es' => enabled
          ? 'Los gráficos con cripto usan $provider. Los rangos cripto siguen limitados a 1 año en el perfil sin claves.'
          : 'Los gráficos cripto están desactivados en esta compilación para mantener el perfil de lanzamiento seguro para la publicación en las tiendas.',
      'de' => enabled
          ? 'Charts mit Krypto verwenden $provider. Krypto-Bereiche bleiben im schlüssellosen Profil auf 1 Jahr begrenzt.'
          : 'Krypto-Charts sind in diesem Build deaktiviert, damit das Release-Profil für die Store-Veröffentlichung sicher bleibt.',
      'it' => enabled
          ? 'I grafici con crypto usano $provider. Gli intervalli crypto restano limitati a 1 anno nel profilo senza chiavi.'
          : 'I grafici crypto sono disattivati in questa build per mantenere sicuro il profilo di rilascio per la pubblicazione negli store.',
      'fr' => enabled
          ? 'Les graphiques impliquant des cryptos utilisent $provider. Les plages crypto restent limitées à 1 an sur le profil sans clé.'
          : 'Les graphiques crypto sont désactivés dans cette build afin de garder le profil de sortie sûr pour la publication sur les stores.',
      _ => enabled
          ? 'Crypto-involved charts use $provider. Crypto ranges stay limited to 1 year on the no-key path.'
          : 'Crypto charts are disabled in this build to keep the release profile safe for store publication.',
    };

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
