part of 'ui_copy.dart';

String chartDailyDataLabel(BuildContext context, DateTime checkedAt) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final date = DateFormat.MMMd(locale).format(checkedAt);
  return switch (_lang(context)) {
    'es' => 'Datos diarios · Comprobado $date',
    'de' => 'Tagesdaten · Geprüft am $date',
    'it' => 'Dati giornalieri · Verificati il $date',
    'fr' => 'Données quotidiennes · Vérifiées le $date',
    _ => 'Daily data · Checked $date',
  };
}

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

String selectBaseCurrencyForChart(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'Seleccionar divisa base',
      'de' => 'Basiswährung auswählen',
      'it' => 'Seleziona valuta base',
      'fr' => 'Sélectionner la devise de base',
      _ => 'Select base currency',
    };

String selectQuoteCurrencyForChart(BuildContext context) =>
    switch (_lang(context)) {
      'es' => 'Seleccionar divisa de destino',
      'de' => 'Kurswährung auswählen',
      'it' => 'Seleziona valuta di destinazione',
      'fr' => 'Sélectionner la devise cible',
      _ => 'Select quote currency',
    };

String chartPairSubtitle(BuildContext context, String base, String quote) =>
    switch (_lang(context)) {
      'es' => 'Par $base/$quote',
      'de' => 'Paar $base/$quote',
      'it' => 'Coppia $base/$quote',
      'fr' => 'Paire $base/$quote',
      _ => '$base/$quote pair',
    };

String chartRangeLabel(BuildContext context, String key) =>
    switch (_lang(context)) {
      'es' => switch (key) {
        '1W' => '1S',
        '1M' => '1M',
        '3M' => '3M',
        '6M' => '6M',
        '1Y' => '1A',
        '2Y' => '2A',
        _ => key,
      },
      'de' => switch (key) {
        '1Y' => '1J',
        '2Y' => '2J',
        _ => key,
      },
      'it' => switch (key) {
        '1W' => '1S',
        '1Y' => '1A',
        '2Y' => '2A',
        _ => key,
      },
      'fr' => switch (key) {
        '1W' => '1S',
        '1Y' => '1A',
        '2Y' => '2A',
        _ => key,
      },
      _ => key,
    };

String cryptoRangeLimitMessage(BuildContext context) => switch (_lang(
  context,
)) {
  'es' => 'Los gráficos cripto admiten hasta 1A con proveedores sin clave',
  'de' => 'Krypto-Charts unterstützen bis zu 1J mit anbieter ohne Schlüssel',
  'it' => 'I grafici crypto supportano fino a 1A con provider senza chiave',
  'fr' =>
    "Les graphiques crypto prennent en charge jusqu'à 1A avec des fournisseurs sans clé",
  _ => 'Crypto charts support up to 1Y with no-key providers',
};

String chartErrorTitle(BuildContext context, String? message) {
  return switch (message) {
    'Crypto charts are not available in this release.' => switch (_lang(
      context,
    )) {
      'es' => 'Los gráficos cripto no están disponibles en esta versión',
      'de' => 'Krypto-Charts sind in dieser Version nicht verfügbar',
      'it' => 'I grafici crypto non sono disponibili in questa versione',
      'fr' =>
        'Les graphiques crypto ne sont pas disponibles dans cette version',
      _ => 'Crypto charts are unavailable in this version',
    },
    'Selected range is not available yet.' => switch (_lang(context)) {
      'es' => 'Este periodo aún no está disponible',
      'de' => 'Dieser Zeitraum ist noch nicht verfügbar',
      'it' => 'Questo periodo non è ancora disponibile',
      'fr' => "Cette période n'est pas encore disponible",
      _ => 'This range is not available yet',
    },
    _ => switch (_lang(context)) {
      'es' => 'No se puede cargar el gráfico',
      'de' => 'Chart konnte nicht geladen werden',
      'it' => 'Impossibile caricare il grafico',
      'fr' => 'Impossible de charger le graphique',
      _ => 'Unable to load chart',
    },
  };
}

String chartErrorSubtitle(BuildContext context) => switch (_lang(context)) {
  'es' => 'Comprueba tu conexión e inténtalo de nuevo',
  'de' => 'Prüfe deine Verbindung und versuche es erneut',
  'it' => 'Controlla la connessione e riprova',
  'fr' => 'Vérifiez votre connexion et réessayez',
  _ => 'Check your connection and try again',
};

String chartsEmptySubtitle(BuildContext context) => switch (_lang(context)) {
  'es' => 'Prueba otro periodo o par de divisas',
  'de' => 'Versuche einen anderen Zeitraum oder ein anderes Währungspaar',
  'it' => 'Prova un altro periodo o una coppia di valute',
  'fr' => 'Essayez une autre période ou paire de devises',
  _ => 'Try another range or currency pair',
};

String noCurrenciesFound(BuildContext context) => switch (_lang(context)) {
  'es' => 'No se han encontrado divisas',
  'de' => 'Keine Währungen gefunden',
  'it' => 'Nessuna valuta trovata',
  'fr' => 'Aucune devise trouvée',
  _ => 'No currencies found',
};
