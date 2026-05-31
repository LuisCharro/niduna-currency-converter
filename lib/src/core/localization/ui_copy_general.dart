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
      'es' => 'Base actual $base · fiat y cripto',
      'de' => 'Aktuelle Basis $base · Fiat und Krypto',
      'it' => 'Base attuale $base · fiat e crypto',
      'fr' => 'Base actuelle $base · fiat et crypto',
      _ => 'Current base $base · fiat and crypto',
    };

String shownBaseSubtitle(BuildContext context, int count, String base) =>
    switch (_lang(context)) {
      'es' => '$count visibles · base $base',
      'de' => '$count sichtbar · Basis $base',
      'it' => '$count visibili · base $base',
      'fr' => '$count affichées · base $base',
      _ => '$count shown · $base base',
    };
