import 'package:flutter/widgets.dart';

import '../../../core/monetization/purchase_service.dart';

String upgradeProductDescription(BuildContext context, ProductType product) {
  final language = Localizations.localeOf(context).languageCode;
  return switch (product) {
    ProductType.removeAds => switch (language) {
      'de' => 'Dauerhaft auf diesem Gerät',
      'es' => 'Para siempre en este dispositivo',
      'fr' => 'À vie sur cet appareil',
      'it' => 'Per sempre su questo dispositivo',
      _ => 'Lifetime on this device',
    },
    ProductType.chartsPro => switch (language) {
      'de' => 'Alle Paare dauerhaft freischalten',
      'es' => 'Desbloquea todos los pares para siempre',
      'fr' => 'Débloque toutes les paires à vie',
      'it' => 'Sblocca tutte le coppie per sempre',
      _ => 'Unlock all pairs forever',
    },
    ProductType.favoritesPro => switch (language) {
      'de' => 'Bis zu 16 Paare speichern',
      'es' => 'Guarda hasta 16 pares',
      'fr' => 'Sauvegarde jusqu’à 16 paires',
      'it' => 'Salva fino a 16 coppie',
      _ => 'Save up to 16 pairs forever',
    },
    ProductType.subscription => '',
  };
}
