part of 'ui_copy.dart';

String chartJustUpdated(BuildContext context) => switch (_lang(context)) {
      'es' => 'Actualizado ahora',
      'de' => 'Gerade aktualisiert',
      'it' => 'Appena aggiornato',
      "fr" => "Mis à jour à l'instant",
      _ => 'Just updated',
    };

String chartUpdatedMinutesAgo(BuildContext context, int minutes) =>
    switch (_lang(context)) {
      'es' => 'Actualizado hace $minutes min',
      'de' => 'Vor $minutes Min. aktualisiert',
      'it' => 'Aggiornato $minutes min fa',
      'fr' => 'Mis à jour il y a $minutes min',
      _ => 'Updated ${minutes}m ago',
    };

String chartUpdatedHoursAgo(BuildContext context, int hours) =>
    switch (_lang(context)) {
      'es' => 'Actualizado hace $hours h',
      'de' => 'Vor $hours Std. aktualisiert',
      'it' => 'Aggiornato $hours h fa',
      'fr' => 'Mis à jour il y a $hours h',
      _ => 'Updated ${hours}h ago',
    };

String chartUpdatedDaysAgo(BuildContext context, int days) =>
    switch (_lang(context)) {
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
      'es' =>
        'Los rangos intradía llegarán pronto; requieren suscripción Premium',
      'de' =>
        'Intraday-Bereiche kommen bald und erfordern ein Premium-Abonnement',
      'it' =>
        'Gli intervalli intraday arriveranno presto; richiedono un abbonamento Premium',
      'fr' =>
        'Les plages intrajournalières arrivent bientôt et nécessitent un abonnement Premium',
      _ =>
        'Intraday ranges coming soon — requires Premium Subscription',
    };

String cryptoRangeLimitMessage(BuildContext context) =>
    switch (_lang(context)) {
      'es' =>
        'Los gráficos cripto admiten hasta 1A con proveedores sin clave',
      'de' =>
        'Krypto-Charts unterstützen bis zu 1J mit anbieter ohne Schlüssel',
      'it' =>
        'I grafici crypto supportano fino a 1A con provider senza chiave',
      'fr' =>
        "Les graphiques crypto prennent en charge jusqu'à 1A avec des fournisseurs sans clé",
      _ =>
        'Crypto charts support up to 1Y with no-key providers',
    };
