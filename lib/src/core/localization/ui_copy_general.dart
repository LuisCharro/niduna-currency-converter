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
      'es' => 'Base actual $base',
      'de' => 'Aktuelle Basis $base',
      'it' => 'Base attuale $base',
      'fr' => 'Base actuelle $base',
      _ => 'Current base $base',
    };

String shownBaseSubtitle(BuildContext context, int count, String base) =>
    switch (_lang(context)) {
      'es' => '$count visibles · base $base',
      'de' => '$count sichtbar · Basis $base',
      'it' => '$count visibili · base $base',
      'fr' => '$count affichées · base $base',
      _ => '$count shown · $base base',
    };
