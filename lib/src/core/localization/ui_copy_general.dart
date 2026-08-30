part of 'ui_copy.dart';

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

String currentBaseSubtitle(BuildContext context, String base) =>
    switch (_lang(context)) {
      'es' => 'Base actual $base · solo fiat',
      'de' => 'Aktuelle Basis $base · nur Fiat',
      'it' => 'Base attuale $base · solo fiat',
      'fr' => 'Base actuelle $base · fiat uniquement',
      _ => 'Current base $base · fiat only',
    };

String shownBaseSubtitle(BuildContext context, int count, String base) =>
    switch (_lang(context)) {
      'es' => '$count visibles · base $base',
      'de' => '$count sichtbar · Basis $base',
      'it' => '$count visibili · base $base',
      'fr' => '$count affichées · base $base',
      _ => '$count shown · $base base',
    };
