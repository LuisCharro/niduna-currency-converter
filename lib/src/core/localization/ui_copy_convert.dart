part of 'ui_copy.dart';

String dailyRatesTooltip(BuildContext context) => switch (_lang(context)) {
      'es' =>
        'Los tipos se actualizan una vez al día. Toca para ver detalles.',
      'de' =>
        'Kurse werden einmal täglich aktualisiert. Tippe für Details.',
      'it' =>
        'I tassi si aggiornano una volta al giorno. Tocca per i dettagli.',
      'fr' =>
        'Les taux sont mis à jour une fois par jour. Touchez pour les détails.',
      _ => 'Rates update once per day. Tap for details.',
    };

String loadingDailyRates(BuildContext context) => switch (_lang(context)) {
      'es' => 'Cargando tipos diarios…',
      'de' => 'Tageskurse werden geladen…',
      'it' => 'Caricamento tassi giornalieri…',
      'fr' => 'Chargement des taux quotidiens…',
      _ => 'Loading daily rates…',
    };

String refreshingRates(BuildContext context, String lastUpdatedLabel) =>
    switch (_lang(context)) {
      'es' => 'Actualizando · $lastUpdatedLabel',
      'de' => 'Aktualisieren · $lastUpdatedLabel',
      'it' => 'Aggiornamento · $lastUpdatedLabel',
      'fr' => 'Actualisation · $lastUpdatedLabel',
      _ => 'Refreshing · $lastUpdatedLabel',
    };

String cachedRatesLabel(BuildContext context, String lastUpdatedLabel) =>
    switch (_lang(context)) {
      'es' => 'En caché · $lastUpdatedLabel',
      'de' => 'Zwischengespeichert · $lastUpdatedLabel',
      'it' => 'In cache · $lastUpdatedLabel',
      'fr' => 'En cache · $lastUpdatedLabel',
      _ => 'Cached · $lastUpdatedLabel',
    };

String offlineRatesUnavailable(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'Sin conexión — tipos no disponibles',
      'de' => 'Offline — Kurse nicht verfügbar',
      'it' => 'Offline — tassi non disponibili',
      'fr' => 'Hors ligne — taux indisponibles',
      _ => 'Offline — rates unavailable',
    };

String freshRatesLabel(BuildContext context, String lastUpdatedLabel) =>
    switch (_lang(context)) {
      'es' => 'Actualizados · $lastUpdatedLabel',
      'de' => 'Aktuell · $lastUpdatedLabel',
      'it' => 'Aggiornati · $lastUpdatedLabel',
      'fr' => 'À jour · $lastUpdatedLabel',
      _ => 'Fresh · $lastUpdatedLabel',
    };

String dailyRatesBody(BuildContext context) => switch (_lang(context)) {
      'es' =>
        'La versión gratuita actualiza los tipos de cambio una vez al día. Son útiles para conversiones cotidianas, pero no son precios de mercado al minuto.',
      'de' =>
        'Die kostenlose Version aktualisiert Wechselkurse einmal täglich. Sie sind für alltägliche Umrechnungen nützlich, aber keine minutengenauen Marktpreise.',
      'it' =>
        'La versione gratuita aggiorna i tassi di cambio una volta al giorno. Sono utili per le conversioni quotidiane, ma non sono prezzi di mercato al minuto.',
      'fr' =>
        'La version gratuite met à jour les taux de change une fois par jour. Ils sont utiles pour les conversions quotidiennes, mais ne sont pas des prix de marché à la minute.',
      _ =>
        'The free version updates exchange rates once per day. They are useful for everyday conversion, but they are not minute-by-minute market prices.',
    };

String nextUpdateLocalTime(BuildContext context) => switch (_lang(context)) {
      'es' =>
        'La próxima actualización estimada se muestra en tu hora local.',
      'de' =>
        'Die nächste erwartete Aktualisierung wird in deiner Ortszeit angezeigt.',
      'it' =>
        'Il prossimo aggiornamento previsto è mostrato nel tuo fuso orario locale.',
      'fr' =>
        'La prochaine mise à jour estimée est affichée dans votre heure locale.',
      _ => 'The next expected update is shown in your local time.',
    };

String fasterUpdatesPlanned(BuildContext context) => switch (_lang(context)) {
      'es' =>
        'Se prevén actualizaciones más rápidas en una futura suscripción Premium.',
      'de' =>
        'Schnellere Aktualisierungen sind für ein zukünftiges Premium-Abonnement geplant.',
      'it' =>
        'Aggiornamenti più rapidi sono previsti per un futuro abbonamento Premium.',
      'fr' =>
        'Des mises à jour plus rapides sont prévues pour un futur abonnement Premium.',
      _ =>
        'Faster updates are planned for a future Premium subscription.',
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

String copiedConversionMessage(BuildContext context, String value) =>
    switch (_lang(context)) {
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

String convertPickerBaseSubtitle(BuildContext context, String code) =>
    switch (_lang(context)) {
      'es' => '$code · divisa base',
      'de' => '$code · Basiswährung',
      'it' => '$code · valuta base',
      'fr' => '$code · devise de base',
      _ => '$code · base currency',
    };

String convertPickerShownSubtitle(BuildContext context, String code) =>
    switch (_lang(context)) {
      'es' => '$code · visible ahora',
      'de' => '$code · jetzt sichtbar',
      'it' => '$code · visibile ora',
      'fr' => '$code · affichée maintenant',
      _ => '$code · shown now',
    };

String convertPickerTapToAddSubtitle(BuildContext context, String code) =>
    switch (_lang(context)) {
      'es' => '$code · toca para añadir',
      'de' => '$code · tippen zum Hinzufügen',
      'it' => '$code · tocca per aggiungere',
      'fr' => '$code · touchez pour ajouter',
      _ => '$code · tap to add',
    };
