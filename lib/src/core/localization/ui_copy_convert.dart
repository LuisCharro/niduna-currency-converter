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
    'Tipos diarios orientativos, no precios en tiempo real. Los bancos y proveedores de pago pueden usar otros tipos o cobrar comisiones.',
  'de' =>
    'Ungefähre Tageskurse, keine Live-Preise. Banken und Zahlungsanbieter können andere Kurse verwenden oder Gebühren berechnen.',
  'it' =>
    'Tassi giornalieri indicativi, non prezzi in tempo reale. Banche e servizi di pagamento possono applicare tassi diversi o commissioni.',
  'fr' =>
    'Taux journaliers indicatifs, pas des prix en temps réel. Les banques et prestataires de paiement peuvent appliquer d’autres taux ou des frais.',
  _ =>
    'Indicative daily rates, not live prices. Banks and payment providers may use different rates or charge fees.',
};

String providerPublicationTiming(BuildContext context) => switch (_lang(
  context,
)) {
  'es' =>
    'La fecha disponible puede retrasarse los fines de semana y festivos.',
  'de' =>
    'Das verfügbare Datum kann an Wochenenden und Feiertagen zurückliegen.',
  'it' =>
    'La data disponibile può essere indietro nei fine settimana e festivi.',
  'fr' =>
    'La date disponible peut accuser un retard les week-ends et jours fériés.',
  _ => 'Available dates may lag on weekends and public holidays.',
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
  'es' => 'Fijar importe',
  'de' => 'Betrag setzen',
  'it' => 'Importo',
  'fr' => 'Définir le montant',
  _ => 'Set amount',
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

String convertRowActionsHintText(BuildContext context) =>
    switch (_lang(context)) {
      'es' =>
        'Truco: mantén pulsada una fila para abrir la lupa · desliza a la izquierda para más',
      'de' =>
        'Tipp: Zeile gedrückt halten öffnet die Lupe · nach links wischen für mehr',
      'it' =>
        'Suggerimento: tieni premuta una riga per aprire la lente · scorri a sinistra per altro',
      'fr' =>
        'Astuce : maintenez une ligne pour ouvrir la loupe · balayez à gauche pour plus',
      _ => 'Tip: hold a row to open the lens · swipe left for more',
    };

String shareRatesFailedMessage(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'No se pudieron compartir los tipos. Inténtalo de nuevo',
      'de' => 'Kurse konnten nicht geteilt werden. Versuche es erneut',
      'it' => 'Impossibile condividere i tassi. Riprova',
      'fr' => 'Impossible de partager les taux. Réessayez',
      _ => 'Couldn’t share the rates. Try again',
    };
