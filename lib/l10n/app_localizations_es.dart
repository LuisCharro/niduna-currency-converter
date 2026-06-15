// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Conversor de divisas';

  @override
  String get tabConvert => 'Convertir';

  @override
  String get tabFavorites => 'Favoritos';

  @override
  String get tabCharts => 'Gráfico';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get btnSwap => 'Cambiar';

  @override
  String get btnClear => 'Borrar';

  @override
  String get btnRemove => 'Quitar';

  @override
  String get btnAdd => 'Añadir divisas';

  @override
  String get btnDone => 'Listo';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnBuy => 'Comprar';

  @override
  String get btnRefresh => 'Actualizar';

  @override
  String get labelFrom => 'De';

  @override
  String get labelTo => 'A';

  @override
  String get labelAmount => 'Cantidad';

  @override
  String get labelResult => 'Resultado';

  @override
  String get labelRate => 'Tipo';

  @override
  String get labelLastUpdated => 'Última actualización';

  @override
  String get labelNoFavorites => 'Aún no hay favoritos';

  @override
  String get labelAddFavorite => 'Añadir favorito';

  @override
  String get favoritesLocalSubtitle =>
      'Pares locales guardados en este dispositivo';

  @override
  String get favoritesEmptyBody =>
      'Desliza una fila de divisa a la izquierda en Convertir y toca Fijar.';

  @override
  String get favoritesOpenConvert => 'Abrir Convertir';

  @override
  String get favoritesLimitMessage =>
      'Puedes fijar hasta 3 pares en esta versión.';

  @override
  String get favoritesCachedRate => 'Tipo diario guardado';

  @override
  String get favoritesRateUnavailable => '--';

  @override
  String get removeFavoriteTooltip => 'Quitar favorito';

  @override
  String get reorderFavoriteTooltip => 'Reordenar favorito';

  @override
  String get openFavoriteTooltip => 'Abrir par en Convertir';

  @override
  String get favoriteActionPin => 'Fijar';

  @override
  String get favoriteActionSaved => 'Fijado';

  @override
  String get labelRemoveAds => 'Quitar anuncios';

  @override
  String get labelDarkMode => 'Modo oscuro';

  @override
  String get labelDarkModeOn => 'Activado';

  @override
  String get labelDarkModeFollowsSystem => 'Seguir sistema';

  @override
  String get labelAbout => 'Acerca de';

  @override
  String get labelVersion => 'Versión';

  @override
  String get labelPrivacy => 'Privacidad';

  @override
  String get labelNoAccount => 'Sin cuenta';

  @override
  String get labelNoCloudSync => 'Sin sincronización en la nube';

  @override
  String get labelNoAnalytics => 'Sin analítica';

  @override
  String get labelOfflineMode => 'Modo sin conexión';

  @override
  String get labelCachedRates => 'Tipos en caché';

  @override
  String get labelConversion => 'Conversión';

  @override
  String get labelData => 'Datos';

  @override
  String get labelPremium => 'Premium';

  @override
  String get labelDefaultBaseCurrency => 'Divisa base predeterminada';

  @override
  String get labelDecimalPlaces => 'Decimales';

  @override
  String get labelRefreshOnOpen => 'Actualizar al abrir';

  @override
  String get labelRefreshOnOpenSubtitle =>
      'Obtener nuevos tipos cuando se inicia la app';

  @override
  String get labelDataSources => 'Fuentes de datos';

  @override
  String get labelClearAllData => 'Borrar todos los datos';

  @override
  String get labelClearAllDataSubtitle =>
      'Tipos fiat, tipos cripto, historial de gráficos y desbloqueos temporales';

  @override
  String get labelSubscription => 'Suscripción';

  @override
  String get labelSubscriptionSubtitle => 'No disponible en v1';

  @override
  String get labelRestorePurchases => 'Restaurar compras';

  @override
  String get labelRestorePurchasesSubtitle =>
      'Volver a comprobar las compras locales en este dispositivo';

  @override
  String get labelSoon => 'Próximamente';

  @override
  String get premiumUnlocks => 'Ventajas Premium';

  @override
  String get premiumActive => 'Premium activo';

  @override
  String get oneTimePurchaseNote =>
      'Compras de pago único; no se necesita cuenta.';

  @override
  String get paidUnlocksStay => 'Las compras permanecen en este dispositivo.';

  @override
  String get ownedOnDevice => 'Comprado en este dispositivo';

  @override
  String get chartsProTitle => 'Charts Pro';

  @override
  String get dataSourcesSubtitle =>
      'Frankfurter, BCE, fuentes cripto y disponibilidad de gráficos';

  @override
  String get versionTapHint =>
      'Toca 7 veces para desbloquear las opciones de desarrollador';

  @override
  String get noRatesTitle => 'Aún no hay tipos';

  @override
  String get noRatesSubtitle =>
      'Desliza para actualizar o toca sincronizar cuando vuelvas a estar en línea';

  @override
  String get dailyRatesTitle => 'Tipos de cambio diarios';

  @override
  String get quickAmounts => 'Cantidades rápidas';

  @override
  String get amountSheetTitle => 'Introducir cantidad';

  @override
  String get selectBaseCurrency => 'Seleccionar divisa base';

  @override
  String get searchCurrencies => 'Divisa, país o código';

  @override
  String get searchCodeOrName => 'Buscar código o nombre';

  @override
  String get addCurrenciesTitle => 'Añadir divisas';

  @override
  String get conversionLensTitle => 'Lente de conversión';

  @override
  String get staleRateWarning =>
      'Tipos desactualizados: los valores pueden diferir del mercado actual';

  @override
  String get errorNetworkFailed => 'Error de red. Se usan los tipos en caché.';

  @override
  String get errorNoData => 'No hay datos disponibles';

  @override
  String get msgFavoriteAdded => 'Favorito añadido';

  @override
  String get msgFavoriteRemoved => 'Favorito eliminado';

  @override
  String get purchasing => 'Comprando…';

  @override
  String get processingPayment => 'Procesando pago…';

  @override
  String get purchaseComplete => '¡Compra completada!';

  @override
  String get purchaseFailed => 'La compra ha fallado';

  @override
  String get pleaseWait => 'Espera…';

  @override
  String get tryAgainLater => 'Inténtalo de nuevo más tarde';

  @override
  String get removingAds => 'Quitando anuncios…';

  @override
  String get unlockingPairs => 'Desbloqueando todos los pares…';

  @override
  String get startingSubscription => 'Iniciando suscripción…';

  @override
  String get adsRemovedForever => 'Todos los anuncios eliminados para siempre';

  @override
  String get allPairsUnlocked => 'Todos los pares de gráficos desbloqueados';

  @override
  String get subscriptionActive => 'Suscripción activa';

  @override
  String get dataDetailsTitle => 'Detalles de los datos';

  @override
  String get dataPolicyTitle => 'Política diaria de datos';

  @override
  String get dataPrivacyLine =>
      'Esta app usa datos de tipos de cambio para mostrar conversiones y gráficos. Tus datos permanecen en este dispositivo.';

  @override
  String get updatesTitle => 'Actualizaciones';

  @override
  String get updatesLine1 =>
      'Los tipos se actualizan como máximo una vez al día.';

  @override
  String get updatesLine2 =>
      'Actualizar al abrir solo comprueba nuevos datos cuando los guardados son antiguos.';

  @override
  String get updatesLine3 =>
      'Aun así, puedes usar la actualización manual para solicitar la última actualización diaria.';

  @override
  String get fiatDataTitle => 'Datos fiat';

  @override
  String get fiatDataLine1 =>
      'Los tipos fiat proceden de Frankfurter usando datos del BCE.';

  @override
  String get fiatDataLine2 =>
      'Los gráficos fiat pueden mostrar hasta 2 años de historial diario.';

  @override
  String get fiatDataLine3 =>
      'Si estás sin conexión, la app usa los datos guardados cuando están disponibles.';

  @override
  String get cryptoDataTitle => 'Datos cripto';

  @override
  String get clearDataTitle => 'Borrar datos';

  @override
  String get clearDataLine1 =>
      'Borrar todos los datos elimina de este dispositivo los tipos y el historial de gráficos guardados.';

  @override
  String get clearDataLine2 =>
      'También elimina los desbloqueos temporales de gráficos.';

  @override
  String get clearDataLine3 =>
      'No elimina el tema ni los ajustes normales de la app.';

  @override
  String get favoritesProTitle => 'Favorites Pro';

  @override
  String get favoritesLimitMessageUpgrade =>
      'Pin up to 3 pairs. Watch an ad or upgrade to add more.';

  @override
  String favoritesPairsHidden(Object count) {
    return '$count pairs hidden';
  }

  @override
  String get favoritesWatchAdToShow => 'Watch ad to see all';

  @override
  String get favoritesUnlockForever => 'Unlock 16 pairs forever';

  @override
  String get favoritesLimitReached => 'Favorites limit reached';

  @override
  String favoritesLimitActionSubtitle(Object freeLimit, Object storedCount) {
    return 'You\'ve pinned $storedCount of $freeLimit free pairs';
  }

  @override
  String get watchAdToAddMore => 'Watch ad to add 3 more';

  @override
  String get unlockingFavoritesPro => 'Unlocking Favorites Pro';

  @override
  String get favoritesProUnlocked => 'Up to 16 favorite pairs unlocked';

  @override
  String get labelDarkModeOff => 'Desactivado';
}
