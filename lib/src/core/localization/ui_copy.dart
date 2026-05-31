import 'package:flutter/widgets.dart';

String _lang(BuildContext context) => Localizations.localeOf(context).languageCode;

String convertHeaderLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Convertir',
  'de' => 'Umrechnen',
  'it' => 'Converti',
  'fr' => 'Convertir',
  _ => 'Convert',
};

String chartsHeaderLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Gráfico',
  'de' => 'Chart',
  'it' => 'Grafico',
  'fr' => 'Graphique',
  _ => 'Charts',
};

String currentBaseSubtitle(BuildContext context, String base) => switch (_lang(context)) {
  'es' => 'Base actual $base · fiat y cripto',
  'de' => 'Aktuelle Basis $base · Fiat und Krypto',
  'it' => 'Base attuale $base · fiat e crypto',
  'fr' => 'Base actuelle $base · fiat et crypto',
  _ => 'Current base $base · fiat and crypto',
};

String shownBaseSubtitle(BuildContext context, int count, String base) => switch (_lang(context)) {
  'es' => '$count visibles · base $base',
  'de' => '$count sichtbar · Basis $base',
  'it' => '$count visibili · base $base',
  'fr' => '$count affichées · base $base',
  _ => '$count shown · $base base',
};

String dailyRatesTooltip(BuildContext context) => switch (_lang(context)) {
  'es' => 'Los tipos se actualizan una vez al día. Toca para ver detalles.',
  'de' => 'Kurse werden einmal täglich aktualisiert. Tippe für Details.',
  'it' => 'I tassi si aggiornano una volta al giorno. Tocca per i dettagli.',
  'fr' => 'Les taux sont mis à jour une fois par jour. Touchez pour les détails.',
  _ => 'Rates update once per day. Tap for details.',
};

String loadingDailyRates(BuildContext context) => switch (_lang(context)) {
  'es' => 'Cargando tipos diarios…',
  'de' => 'Tageskurse werden geladen…',
  'it' => 'Caricamento tassi giornalieri…',
  'fr' => 'Chargement des taux quotidiens…',
  _ => 'Loading daily rates…',
};

String refreshingRates(BuildContext context, String lastUpdatedLabel) => switch (_lang(context)) {
  'es' => 'Actualizando · $lastUpdatedLabel',
  'de' => 'Aktualisieren · $lastUpdatedLabel',
  'it' => 'Aggiornamento · $lastUpdatedLabel',
  'fr' => 'Actualisation · $lastUpdatedLabel',
  _ => 'Refreshing · $lastUpdatedLabel',
};

String cachedRatesLabel(BuildContext context, String lastUpdatedLabel) => switch (_lang(context)) {
  'es' => 'En caché · $lastUpdatedLabel',
  'de' => 'Zwischengespeichert · $lastUpdatedLabel',
  'it' => 'In cache · $lastUpdatedLabel',
  'fr' => 'En cache · $lastUpdatedLabel',
  _ => 'Cached · $lastUpdatedLabel',
};

String offlineRatesUnavailable(BuildContext context) => switch (_lang(context)) {
  'es' => 'Sin conexión — tipos no disponibles',
  'de' => 'Offline — Kurse nicht verfügbar',
  'it' => 'Offline — tassi non disponibili',
  'fr' => 'Hors ligne — taux indisponibles',
  _ => 'Offline — rates unavailable',
};

String freshRatesLabel(BuildContext context, String lastUpdatedLabel) => switch (_lang(context)) {
  'es' => 'Actualizados · $lastUpdatedLabel',
  'de' => 'Aktuell · $lastUpdatedLabel',
  'it' => 'Aggiornati · $lastUpdatedLabel',
  'fr' => 'À jour · $lastUpdatedLabel',
  _ => 'Fresh · $lastUpdatedLabel',
};

String dailyRatesBody(BuildContext context) => switch (_lang(context)) {
  'es' => 'La versión gratuita actualiza los tipos de cambio una vez al día. Son útiles para conversiones cotidianas, pero no son precios de mercado al minuto.',
  'de' => 'Die kostenlose Version aktualisiert Wechselkurse einmal täglich. Sie sind für alltägliche Umrechnungen nützlich, aber keine minutengenauen Marktpreise.',
  'it' => 'La versione gratuita aggiorna i tassi di cambio una volta al giorno. Sono utili per le conversioni quotidiane, ma non sono prezzi di mercato al minuto.',
  'fr' => 'La version gratuite met à jour les taux de change une fois par jour. Ils sont utiles pour les conversions quotidiennes, mais ne sont pas des prix de marché à la minute.',
  _ => 'The free version updates exchange rates once per day. They are useful for everyday conversion, but they are not minute-by-minute market prices.',
};

String nextUpdateLocalTime(BuildContext context) => switch (_lang(context)) {
  'es' => 'La próxima actualización estimada se muestra en tu hora local.',
  'de' => 'Die nächste erwartete Aktualisierung wird in deiner Ortszeit angezeigt.',
  'it' => 'Il prossimo aggiornamento previsto è mostrato nel tuo fuso orario locale.',
  'fr' => 'La prochaine mise à jour estimée est affichée dans votre heure locale.',
  _ => 'The next expected update is shown in your local time.',
};

String fasterUpdatesPlanned(BuildContext context) => switch (_lang(context)) {
  'es' => 'Se prevén actualizaciones más rápidas en una futura suscripción Premium.',
  'de' => 'Schnellere Aktualisierungen sind für ein zukünftiges Premium-Abonnement geplant.',
  'it' => 'Aggiornamenti più rapidi sono previsti per un futuro abbonamento Premium.',
  'fr' => 'Des mises à jour plus rapides sont prévues pour un futur abonnement Premium.',
  _ => 'Faster updates are planned for a future Premium subscription.',
};

String chartJustUpdated(BuildContext context) => switch (_lang(context)) {
  'es' => 'Actualizado ahora',
  'de' => 'Gerade aktualisiert',
  'it' => 'Appena aggiornato',
  'fr' => 'Mis à jour à l’instant',
  _ => 'Just updated',
};

String chartUpdatedMinutesAgo(BuildContext context, int minutes) => switch (_lang(context)) {
  'es' => 'Actualizado hace $minutes min',
  'de' => 'Vor $minutes Min. aktualisiert',
  'it' => 'Aggiornato $minutes min fa',
  'fr' => 'Mis à jour il y a $minutes min',
  _ => 'Updated ${minutes}m ago',
};

String chartUpdatedHoursAgo(BuildContext context, int hours) => switch (_lang(context)) {
  'es' => 'Actualizado hace $hours h',
  'de' => 'Vor $hours Std. aktualisiert',
  'it' => 'Aggiornato $hours h fa',
  'fr' => 'Mis à jour il y a $hours h',
  _ => 'Updated ${hours}h ago',
};

String chartUpdatedDaysAgo(BuildContext context, int days) => switch (_lang(context)) {
  'es' => 'Actualizado hace $days d',
  'de' => 'Vor $days Tg. aktualisiert',
  'it' => 'Aggiornato $days g fa',
  'fr' => 'Mis à jour il y a $days j',
  _ => 'Updated ${days}d ago',
};

String metricHigh(BuildContext context) => switch (_lang(context)) {
  'es' => 'Máximo',
  'de' => 'Hoch',
  'it' => 'Massimo',
  'fr' => 'Haut',
  _ => 'High',
};

String metricLow(BuildContext context) => switch (_lang(context)) {
  'es' => 'Mínimo',
  'de' => 'Tief',
  'it' => 'Minimo',
  'fr' => 'Bas',
  _ => 'Low',
};

String metricChange(BuildContext context) => switch (_lang(context)) {
  'es' => 'Cambio',
  'de' => 'Änderung',
  'it' => 'Variazione',
  'fr' => 'Variation',
  _ => 'Change',
};

String dataSourceFiatTitle(BuildContext context) => switch (_lang(context)) {
  'es' => 'Fiat actual y gráficos fiat',
  'de' => 'Aktuelle Fiat-Kurse und Fiat-Charts',
  'it' => 'Fiat attuale e grafici fiat',
  'fr' => 'Fiat actuel et graphiques fiat',
  _ => 'Fiat latest and fiat charts',
};

String dataSourceFiatDetail(BuildContext context) => switch (_lang(context)) {
  'es' => 'Frankfurter proporciona los tipos fiat actuales e históricos usados por la app. Los gráficos fiat admiten rangos diarios de hasta 2 años.',
  'de' => 'Frankfurter liefert die aktuellen und historischen Fiat-Wechselkurse der App. Fiat-Charts unterstützen tägliche Bereiche bis zu 2 Jahren.',
  'it' => 'Frankfurter fornisce i tassi fiat attuali e storici usati dall’app. I grafici fiat supportano intervalli giornalieri fino a 2 anni.',
  'fr' => 'Frankfurter fournit les taux fiat actuels et historiques utilisés par l’app. Les graphiques fiat prennent en charge des plages quotidiennes jusqu’à 2 ans.',
  _ => 'Frankfurter provides the fiat latest and historical exchange rates used by the app. Fiat charts support daily ranges up to 2 years.',
};

String dataSourceCryptoLatestTitle(BuildContext context) => switch (_lang(context)) {
  'es' => 'Cripto actual',
  'de' => 'Aktuelle Krypto-Kurse',
  'it' => 'Crypto attuale',
  'fr' => 'Crypto actuel',
  _ => 'Crypto latest',
};

String dataSourceCryptoLatestDetail(BuildContext context) => switch (_lang(context)) {
  'es' => 'Los últimos precios de cripto usan la cadena activa de proveedor cripto de esta compilación. Los detalles del perfil de desarrollador solo se muestran dentro del Dev Sandbox.',
  'de' => 'Die neuesten Krypto-Preise verwenden die aktive Krypto-Anbieterkette dieses Builds. Details zum Entwicklerprofil werden nur in der Dev Sandbox angezeigt.',
  'it' => 'I prezzi più recenti delle crypto usano la catena di provider crypto attiva per questa build. I dettagli del profilo sviluppatore sono mostrati solo nel Dev Sandbox.',
  'fr' => 'Les derniers prix crypto utilisent la chaîne de fournisseurs crypto active pour cette build. Les détails du profil développeur ne sont affichés que dans le Dev Sandbox.',
  _ => 'Crypto latest prices use the active crypto provider chain for this build. Developer profile details are shown only inside the Dev Sandbox.',
};

String dataSourceCryptoChartsTitle(BuildContext context) => switch (_lang(context)) {
  'es' => 'Gráficos cripto',
  'de' => 'Krypto-Charts',
  'it' => 'Grafici crypto',
  'fr' => 'Graphiques crypto',
  _ => 'Crypto charts',
};

String dataSourceCryptoChartsDetail(BuildContext context, String provider, bool enabled) {
  return switch (_lang(context)) {
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
}

String selectBaseCurrencyForChart(BuildContext context) => switch (_lang(context)) {
  'es' => 'Seleccionar divisa base',
  'de' => 'Basiswährung auswählen',
  'it' => 'Seleziona valuta base',
  'fr' => 'Sélectionner la devise de base',
  _ => 'Select base currency',
};

String selectQuoteCurrencyForChart(BuildContext context) => switch (_lang(context)) {
  'es' => 'Seleccionar divisa de destino',
  'de' => 'Kurswährung auswählen',
  'it' => 'Seleziona valuta di destinazione',
  'fr' => 'Sélectionner la devise cible',
  _ => 'Select quote currency',
};

String chartPairSubtitle(BuildContext context, String base, String quote) => switch (_lang(context)) {
  'es' => 'Par $base/$quote',
  'de' => 'Paar $base/$quote',
  'it' => 'Coppia $base/$quote',
  'fr' => 'Paire $base/$quote',
  _ => '$base/$quote pair',
};

String tapToUnlockLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Toca para desbloquear',
  'de' => 'Tippen zum Freischalten',
  'it' => 'Tocca per sbloccare',
  'fr' => 'Touchez pour déverrouiller',
  _ => 'Tap to unlock',
};

String unlockedFor24hLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Desbloqueado · quedan 24 h',
  'de' => 'Freigeschaltet · 24 Std. verbleibend',
  'it' => 'Sbloccato · restano 24 h',
  'fr' => 'Déverrouillé · 24 h restantes',
  _ => 'Unlocked · 24h remaining',
};

String currentCurrencyLabel(BuildContext context, String code) => switch (_lang(context)) {
  'es' => 'Actual $code',
  'de' => 'Aktuell $code',
  'it' => 'Attuale $code',
  'fr' => 'Actuelle $code',
  _ => 'Current $code',
};

String currentBadgeLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Actual',
  'de' => 'Aktuell',
  'it' => 'Attuale',
  'fr' => 'Actuelle',
  _ => 'Current',
};

String lockedBadgeLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Bloqueado',
  'de' => 'Gesperrt',
  'it' => 'Bloccato',
  'fr' => 'Verrouillé',
  _ => 'Locked',
};

String pairLockedTitle(BuildContext context) => switch (_lang(context)) {
  'es' => 'Este par está bloqueado',
  'de' => 'Dieses Paar ist gesperrt',
  'it' => 'Questa coppia è bloccata',
  'fr' => 'Cette paire est verrouillée',
  _ => 'This pair is locked',
};

String pairLockedSubtitle(BuildContext context, bool canWatchAd) => switch (_lang(context)) {
  'es' => canWatchAd
      ? 'Elige cómo desbloquearlo'
      : 'Los anuncios con recompensa no están disponibles tras Quitar anuncios',
  'de' => canWatchAd
      ? 'Wähle, wie du es freischalten möchtest'
      : 'Belohnungsanzeigen sind nach Werbung entfernen nicht verfügbar',
  'it' => canWatchAd
      ? 'Scegli come sbloccarla'
      : 'Gli annunci con ricompensa non sono disponibili dopo Rimuovi annunci',
  'fr' => canWatchAd
      ? 'Choisissez comment la déverrouiller'
      : 'Les publicités récompensées ne sont plus disponibles après Supprimer les publicités',
  _ => canWatchAd
      ? 'Choose how to unlock it'
      : 'Rewarded ads are unavailable after Remove Ads',
};

String watchAdUnlockLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Ver anuncio · Desbloquear 24 h',
  'de' => 'Anzeige ansehen · 24 Std. freischalten',
  'it' => 'Guarda annuncio · Sblocca per 24 h',
  'fr' => 'Voir la pub · Déverrouiller 24 h',
  _ => 'Watch ad · Unlock for 24h',
};

String unlockAllPairsForeverLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Desbloquear todos los pares para siempre',
  'de' => 'Alle Paare dauerhaft freischalten',
  'it' => 'Sblocca tutte le coppie per sempre',
  'fr' => 'Déverrouiller toutes les paires pour toujours',
  _ => 'Unlock all pairs forever',
};

String closeLensTooltip(BuildContext context) => switch (_lang(context)) {
  'es' => 'Cerrar panel',
  'de' => 'Ansicht schließen',
  'it' => 'Chiudi pannello',
  'fr' => 'Fermer le panneau',
  _ => 'Close lens',
};

String copyConversionTooltip(BuildContext context) => switch (_lang(context)) {
  'es' => 'Copiar conversión al portapapeles',
  'de' => 'Umrechnung in die Zwischenablage kopieren',
  'it' => 'Copia conversione negli appunti',
  'fr' => 'Copier la conversion dans le presse-papiers',
  _ => 'Copy conversion to clipboard',
};

String copiedConversionMessage(BuildContext context, String value) => switch (_lang(context)) {
  'es' => 'Copiado: $value',
  'de' => 'Kopiert: $value',
  'it' => 'Copiato: $value',
  'fr' => 'Copié : $value',
  _ => 'Copied $value',
};

String quickBaseAmountsLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Cantidades base rápidas',
  'de' => 'Schnelle Basisbeträge',
  'it' => 'Importi base rapidi',
  'fr' => 'Montants de base rapides',
  _ => 'Quick base amounts',
};

String reverseTargetsLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Objetivos inversos',
  'de' => 'Umgekehrte Ziele',
  'it' => 'Obiettivi inversi',
  'fr' => 'Cibles inversées',
  _ => 'Reverse targets',
};

String useActionLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'Usar',
  'de' => 'Verwenden',
  'it' => 'Usa',
  'fr' => 'Utiliser',
  _ => 'Use',
};

String ratesSectionLabel(BuildContext context) => switch (_lang(context)) {
  'es' => 'TIPOS',
  'de' => 'KURSE',
  'it' => 'TASSI',
  'fr' => 'TAUX',
  _ => 'RATES',
};

String chartRangeLabel(BuildContext context, String key) => switch (_lang(context)) {
  'es' => switch (key) {
      '1H' => '1H',
      '6H' => '6H',
      '1D' => '1D',
      '1W' => '1S',
      '1M' => '1M',
      '3M' => '3M',
      '6M' => '6M',
      '1Y' => '1A',
      '2Y' => '2A',
      _ => key,
    },
  'de' => switch (key) {
      '1D' => '1T',
      '1Y' => '1J',
      '2Y' => '2J',
      _ => key,
    },
  'it' => switch (key) {
      '1H' => '1O',
      '6H' => '6O',
      '1D' => '1G',
      '1W' => '1S',
      '1Y' => '1A',
      '2Y' => '2A',
      _ => key,
    },
  'fr' => switch (key) {
      '1D' => '1J',
      '1W' => '1S',
      '1Y' => '1A',
      '2Y' => '2A',
      _ => key,
    },
  _ => key,
};

String intradayPremiumMessage(BuildContext context) => switch (_lang(context)) {
  'es' => 'Los rangos intradía llegarán pronto; requieren suscripción Premium',
  'de' => 'Intraday-Bereiche kommen bald und erfordern ein Premium-Abonnement',
  'it' => 'Gli intervalli intraday arriveranno presto; richiedono un abbonamento Premium',
  'fr' => 'Les plages intrajournalières arrivent bientôt et nécessitent un abonnement Premium',
  _ => 'Intraday ranges coming soon — requires Premium Subscription',
};

String cryptoRangeLimitMessage(BuildContext context) => switch (_lang(context)) {
  'es' => 'Los gráficos cripto admiten hasta 1A con proveedores sin clave',
  'de' => 'Krypto-Charts unterstützen bis zu 1J mit anbieter ohne Schlüssel',
  'it' => 'I grafici crypto supportano fino a 1A con provider senza chiave',
  'fr' => 'Les graphiques crypto prennent en charge jusqu’à 1A avec des fournisseurs sans clé',
  _ => 'Crypto charts support up to 1Y with no-key providers',
};

String convertPickerBaseSubtitle(BuildContext context, String code) => switch (_lang(context)) {
  'es' => '$code · divisa base',
  'de' => '$code · Basiswährung',
  'it' => '$code · valuta base',
  'fr' => '$code · devise de base',
  _ => '$code · base currency',
};

String convertPickerShownSubtitle(BuildContext context, String code) => switch (_lang(context)) {
  'es' => '$code · visible ahora',
  'de' => '$code · jetzt sichtbar',
  'it' => '$code · visibile ora',
  'fr' => '$code · affichée maintenant',
  _ => '$code · shown now',
};

String convertPickerTapToAddSubtitle(BuildContext context, String code) => switch (_lang(context)) {
  'es' => '$code · toca para añadir',
  'de' => '$code · tippen zum Hinzufügen',
  'it' => '$code · tocca per aggiungere',
  'fr' => '$code · touchez pour ajouter',
  _ => '$code · tap to add',
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
          'Nei grafici misti fiat/crypto, i valori fiat restano sull’ultima chiusura di mercato disponibile durante fine settimana e festivi.',
      ],
    'fr' => <String>[
        'Les taux crypto suivent le même calendrier quotidien de mise à jour que les taux fiat.',
        enabled
            ? 'Les graphiques crypto affichent un historique quotidien jusqu’à 1 an.'
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
