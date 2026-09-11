part of 'ui_copy.dart';

String dailyRatesTooltip(BuildContext context) => switch (_lang(context)) {
  'es' =>
    'La app comprueba nuevos tipos una vez al día. Toca para ver detalles.',
  'de' => 'Die App prüft einmal täglich neue Kurse. Tippe für Details.',
  'it' =>
    "L'app controlla nuovi tassi una volta al giorno. Tocca per i dettagli.",
  'fr' =>
    "L’app vérifie les nouveaux taux une fois par jour. Touchez pour les détails.",
  _ => 'The app checks for new rates once daily. Tap for details.',
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
      'es' => 'Comprobando tipos diarios · $lastUpdatedLabel',
      'de' => 'Tageskurse werden geprüft · $lastUpdatedLabel',
      'it' => 'Controllo dei tassi giornalieri · $lastUpdatedLabel',
      'fr' => 'Vérification des taux quotidiens · $lastUpdatedLabel',
      _ => 'Checking daily rates · $lastUpdatedLabel',
    };

String cachedRatesLabel(BuildContext context, String lastUpdatedLabel) =>
    switch (_lang(context)) {
      'es' => 'Tipos diarios en caché · $lastUpdatedLabel',
      'de' => 'Gespeicherte Tageskurse · $lastUpdatedLabel',
      'it' => 'Tassi giornalieri in cache · $lastUpdatedLabel',
      'fr' => 'Taux quotidiens en cache · $lastUpdatedLabel',
      _ => 'Cached daily rates · $lastUpdatedLabel',
    };

String offlineRatesUnavailable(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'Sin conexión — tipos no disponibles',
      'de' => 'Offline — Kurse nicht verfügbar',
      'it' => 'Offline — tassi non disponibili',
      'fr' => 'Hors ligne — taux indisponibles',
      _ => 'Offline — rates unavailable',
    };

String dailyRatesLabel(BuildContext context, String lastUpdatedLabel) =>
    switch (_lang(context)) {
      'es' => '1 vez al día · $lastUpdatedLabel',
      'de' => '1× täglich · $lastUpdatedLabel',
      'it' => '1 volta al giorno · $lastUpdatedLabel',
      'fr' => '1 fois par jour · $lastUpdatedLabel',
      _ => '1× daily · $lastUpdatedLabel',
    };

String dailyRatesBody(BuildContext context) => switch (_lang(context)) {
  'es' =>
    'La app comprueba una vez al día los últimos tipos publicados por fuentes públicas. Las fuentes publican a horas distintas, por lo que la fecha disponible puede cambiar durante el día. No son precios de mercado en tiempo real.',
  'de' =>
    'Die App prüft einmal täglich die neuesten Kurse aus öffentlichen Quellen. Die Quellen veröffentlichen zu unterschiedlichen Zeiten, daher kann sich das verfügbare Datum im Tagesverlauf ändern. Es sind keine Echtzeit-Marktpreise.',
  'it' =>
    "L'app controlla una volta al giorno gli ultimi tassi pubblicati da fonti pubbliche. Le fonti pubblicano in orari diversi, quindi la data disponibile può cambiare durante il giorno. Non sono prezzi di mercato in tempo reale.",
  'fr' =>
    'L’app vérifie une fois par jour les derniers taux publiés par des sources publiques. Ces sources publient à des heures différentes, la date disponible peut donc changer au cours de la journée. Il ne s’agit pas de prix de marché en temps réel.',
  _ =>
    'The app checks the latest rates from public sources once daily. Sources publish at different times, so the available rate date can change during the day. These are not live or intraday market prices.',
};

String providerPublicationTiming(BuildContext context) => switch (_lang(
  context,
)) {
  'es' => 'Las fuentes pueden publicar nuevos datos a distintas horas.',
  'de' =>
    'Die Quellen können neue Daten zu unterschiedlichen Zeiten veröffentlichen.',
  'it' => 'Le fonti possono pubblicare nuovi dati in orari diversi.',
  'fr' =>
    'Les sources peuvent publier de nouvelles données à des heures différentes.',
  _ => 'Sources may publish new data at different times.',
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

String shareImageFailedMessage(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'No se pudo crear la imagen. Inténtalo de nuevo',
      'de' => 'Bild konnte nicht erstellt werden. Versuche es erneut',
      'it' => "Impossibile creare l'immagine. Riprova",
      'fr' => "Impossible de créer l'image. Réessayez",
      _ => 'Couldn’t create the image. Try again',
    };

String shareRatesFailedMessage(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'No se pudieron compartir los tipos. Inténtalo de nuevo',
      'de' => 'Kurse konnten nicht geteilt werden. Versuche es erneut',
      'it' => 'Impossibile condividere i tassi. Riprova',
      'fr' => 'Impossible de partager les taux. Réessayez',
      _ => 'Couldn’t share the rates. Try again',
    };
