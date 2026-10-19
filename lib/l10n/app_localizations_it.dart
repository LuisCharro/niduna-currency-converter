// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Convertitore di valute';

  @override
  String get tabConvert => 'Converti';

  @override
  String get tabFavorites => 'Preferiti';

  @override
  String get tabCharts => 'Grafico';

  @override
  String get tabSettings => 'Impostazioni';

  @override
  String get btnSwap => 'Scambia';

  @override
  String get btnClear => 'Cancella';

  @override
  String get btnRemove => 'Rimuovi';

  @override
  String get btnAdd => 'Aggiungi valute';

  @override
  String get btnDone => 'Fatto';

  @override
  String get btnCancel => 'Annulla';

  @override
  String get btnBuy => 'Acquista';

  @override
  String get btnRefresh => 'Aggiorna';

  @override
  String get labelFrom => 'Da';

  @override
  String get labelTo => 'A';

  @override
  String get labelAmount => 'Importo';

  @override
  String get labelResult => 'Risultato';

  @override
  String get labelRate => 'Tasso';

  @override
  String get labelLastUpdated => 'Ultimo aggiornamento';

  @override
  String get labelNoFavorites => 'Fissa le coppie che controlli più spesso';

  @override
  String get labelAddFavorite => 'Aggiungi preferito';

  @override
  String get favoritesLocalSubtitle =>
      'Coppie locali salvate su questo dispositivo';

  @override
  String favoritesEmptyBody(Object limit) {
    return 'Scorri a sinistra su una valuta in Converti e tocca Preferito. Fino a $limit coppie, gratis.';
  }

  @override
  String get favoritesOpenConvert => 'Apri Converti';

  @override
  String get favoritesLimitMessage =>
      'Puoi fissare fino a 3 coppie in questa versione.';

  @override
  String get favoritesCachedRate => 'Tasso giornaliero salvato';

  @override
  String get favoritesRateUnavailable => '--';

  @override
  String get removeFavoriteTooltip => 'Rimuovi preferito';

  @override
  String get reorderFavoriteTooltip => 'Riordina preferito';

  @override
  String get openFavoriteTooltip => 'Apri coppia in Converti';

  @override
  String get favoriteActionPin => 'Preferito';

  @override
  String get favoriteActionSaved => 'Nei preferiti';

  @override
  String get labelRemoveAds => 'Rimuovi annunci';

  @override
  String get labelAbout => 'Informazioni';

  @override
  String get labelVersion => 'Versione';

  @override
  String get labelPrivacy => 'Informativa sulla privacy';

  @override
  String get privacyOptionsTitle => 'Opzioni privacy';

  @override
  String get privacyOptionsSubtitle =>
      'Gestisci il consenso per gli annunci e le scelte sulla privacy';

  @override
  String get labelNoAccount => 'Nessun account';

  @override
  String get labelNoCloudSync => 'Nessuna sincronizzazione cloud';

  @override
  String get labelNoAnalytics => 'Nessuna analisi';

  @override
  String get labelOfflineMode => 'Modalità offline';

  @override
  String get labelCachedRates => 'Tassi in cache';

  @override
  String get labelConversion => 'Conversione';

  @override
  String get labelData => 'Dati';

  @override
  String get labelPremium => 'Premium';

  @override
  String get labelDefaultBaseCurrency => 'Valuta base predefinita';

  @override
  String get labelDecimalPlaces => 'Decimali';

  @override
  String get labelRefreshOnOpen => 'Aggiorna all\'apertura';

  @override
  String get labelRefreshOnOpenSubtitle =>
      'Scarica nuovi tassi all\'avvio dell\'app';

  @override
  String get labelClearAllData => 'Cancella i dati salvati';

  @override
  String get labelClearAllDataSubtitle =>
      'Tassi, cronologia grafici e sblocchi temporanei. Preferiti e impostazioni restano.';

  @override
  String get labelRestorePurchases => 'Ripristina acquisti';

  @override
  String get labelRestorePurchasesSubtitle =>
      'Ricontrolla gli acquisti locali su questo dispositivo';

  @override
  String get premiumUnlocks => 'Vantaggi Premium';

  @override
  String get premiumActive => 'Premium attivo';

  @override
  String get oneTimePurchaseNote =>
      'Acquisti una tantum; nessun account richiesto.';

  @override
  String get paidUnlocksStay => 'Gli acquisti restano su questo dispositivo.';

  @override
  String get ownedOnDevice => 'Acquistato su questo dispositivo';

  @override
  String get chartsProTitle => 'Charts Pro';

  @override
  String get dataSourcesSubtitle =>
      'Un riepilogo e le tue scelte sulla privacy';

  @override
  String get versionTapHint =>
      'Tocca 7 volte per sbloccare le opzioni sviluppatore';

  @override
  String get noRatesTitle => 'Nessun tasso disponibile';

  @override
  String get noRatesSubtitle =>
      'Trascina per aggiornare o tocca sincronizza quando torni online';

  @override
  String get dailyRatesTitle => 'Tassi di cambio giornalieri';

  @override
  String get quickAmounts => 'Importi rapidi';

  @override
  String get amountSheetTitle => 'Inserisci importo';

  @override
  String get selectBaseCurrency => 'Seleziona valuta base';

  @override
  String get searchCurrencies => 'Valuta, paese o codice';

  @override
  String get searchCodeOrName => 'Cerca codice o nome';

  @override
  String get addCurrenciesTitle => 'Aggiungi valute';

  @override
  String get conversionLensTitle => 'Lente di conversione';

  @override
  String get staleRateWarning =>
      'Tassi non aggiornati: i valori possono differire dal mercato attuale';

  @override
  String get errorNetworkFailed => 'Errore di rete. Uso dei tassi in cache.';

  @override
  String get errorNoData => 'Nessun dato disponibile';

  @override
  String get msgFavoriteAdded => 'Preferito aggiunto';

  @override
  String get msgFavoriteRemoved => 'Preferito rimosso';

  @override
  String get purchasing => 'Acquisto in corso…';

  @override
  String get processingPayment => 'Elaborazione pagamento…';

  @override
  String get purchaseComplete => 'Acquisto completato!';

  @override
  String get purchaseFailed => 'Acquisto non riuscito';

  @override
  String get pleaseWait => 'Attendi…';

  @override
  String get tryAgainLater => 'Riprova più tardi';

  @override
  String get removingAds => 'Rimozione annunci…';

  @override
  String get unlockingPairs => 'Sblocco di tutte le coppie…';

  @override
  String get startingSubscription => 'Avvio abbonamento…';

  @override
  String get adsRemovedForever => 'Tutti gli annunci rimossi per sempre';

  @override
  String get allPairsUnlocked => 'Tutte le coppie dei grafici sbloccate';

  @override
  String get subscriptionActive => 'Abbonamento attivo';

  @override
  String get dataDetailsTitle => 'Dati e privacy';

  @override
  String get dataPolicyTitle => 'Politica giornaliera dei dati';

  @override
  String get dataPrivacyLine =>
      'Preferiti e impostazioni restano su questo dispositivo. Servizi esterni forniscono i tassi e Google mostra annunci quando sono attivi.';

  @override
  String get updatesTitle => 'Aggiornamenti';

  @override
  String get updatesLine1 =>
      'Sono tassi giornalieri indicativi, non prezzi in tempo reale.';

  @override
  String get updatesLine2 =>
      'Con l’aggiornamento all’apertura attivo, l’app controlla i nuovi dati alla prima apertura di ogni giorno.';

  @override
  String get updatesLine3 =>
      'Puoi aggiornare manualmente in qualsiasi momento.';

  @override
  String get fiatDataTitle => 'Dati fiat';

  @override
  String get fiatDataLine1 =>
      'Tassi fiat: Frankfurter, basati su dati pubblici delle banche centrali.';

  @override
  String get fiatDataLine2 =>
      'I grafici fiat mostrano fino a 2 anni di storico giornaliero.';

  @override
  String get fiatDataLine3 => 'I tassi salvati sono disponibili offline.';

  @override
  String get cryptoDataTitle => 'Dati crypto';

  @override
  String get clearDataTitle => 'Dati salvati';

  @override
  String get clearDataLine1 =>
      'Cancella i tassi fiat e crypto salvati e la cronologia dei grafici.';

  @override
  String get clearDataLine2 =>
      'Cancella anche gli sblocchi temporanei dei grafici.';

  @override
  String get clearDataLine3 =>
      'Preferiti, tema e impostazioni dell’app restano.';

  @override
  String get favoritesProTitle => 'Favorites Pro';

  @override
  String get favoritesLimitMessageUpgrade =>
      'Pin up to 3 pairs. Watch an ad or upgrade to add more.';

  @override
  String favoritesPairsHidden(Object count) {
    return '$count coppie nascoste';
  }

  @override
  String get favoritesWatchAdToShow => 'Guarda un annuncio per vederle tutte';

  @override
  String get favoritesUnlockForever => 'Sblocca 16 coppie per sempre';

  @override
  String get favoritesLimitReached => 'Favorites limit reached';

  @override
  String favoritesLimitActionSubtitle(Object freeLimit, Object storedCount) {
    return 'You\'ve pinned $storedCount of $freeLimit free pairs';
  }

  @override
  String get watchAdToAddMore => 'Guarda un annuncio per aggiungerne altre 3';

  @override
  String get unlockingFavoritesPro => 'Unlocking Favorites Pro';

  @override
  String get favoritesProUnlocked => 'Up to 16 favorite pairs unlocked';

  @override
  String get refreshRatesTooltip => 'Aggiorna tassi';

  @override
  String get shareRatesTooltip => 'Condividi tassi';

  @override
  String get openSettingsTooltip => 'Impostazioni';

  @override
  String get closeTooltip => 'Chiudi';

  @override
  String get removeCurrencyLabel => 'Rimuovi valuta';

  @override
  String get toggleFavoriteLabel => 'Aggiungi o rimuovi preferito';

  @override
  String get setAsBaseLabel => 'Imposta come valuta base';

  @override
  String get swapCurrenciesTooltip => 'Scambia valute';

  @override
  String get rateFreshnessInfoLabel =>
      'Informazioni sull\'aggiornamento dei tassi';

  @override
  String get changeChartPairLabel => 'Cambia coppia del grafico';

  @override
  String changeBaseCurrencyLabel(String code) {
    return 'Cambia valuta base, attualmente $code';
  }

  @override
  String editAmountLabel(String amount) {
    return 'Modifica importo, attualmente $amount';
  }

  @override
  String openPairLabel(String code) {
    return 'Apri conversione $code';
  }

  @override
  String chartRangeLabel(String range) {
    return 'Periodo $range';
  }

  @override
  String get cryptoDataSourceLine =>
      'Tassi e grafici crypto: exchange-api di fawazahmed0.';

  @override
  String get clearDataDialogTitle => 'Cancellare i dati salvati?';

  @override
  String get snackCacheCleared => 'Cache cancellata';

  @override
  String get snackRestoreChecking => 'Verifica degli acquisti…';

  @override
  String get labelThemeMode => 'Tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get labelSendFeedback => 'Invia feedback';

  @override
  String get sendFeedbackSubtitle => 'Domande, idee o bug — leggiamo tutto';

  @override
  String feedbackEmailSubject(String version) {
    return 'Feedback su Currency Converter ($version)';
  }

  @override
  String snackNoEmailApp(String email) {
    return 'Nessuna app di posta trovata — contattaci a $email';
  }

  @override
  String favoritesMorePairsHeader(Object effectiveLimit, Object visibleCount) {
    return 'ALTRE COPPIE · $visibleCount DI $effectiveLimit';
  }

  @override
  String get favoritesAddPairSlot => 'Aggiungi una coppia';

  @override
  String get favoritesWantMorePairs => 'Vuoi altre coppie?';

  @override
  String get favoritesWatchAdPillLabel => 'Annuncio +3';

  @override
  String get favoritesProPillLabel => '16 per sempre';

  @override
  String get favoritesFirstPairPreview => 'La tua prima coppia appare qui';

  @override
  String get convertFromTitle => 'Converti da';

  @override
  String get savedCurrenciesSubtitle => 'Scegli una valuta dal tuo elenco';

  @override
  String get addAnotherCurrency => 'Aggiungi un’altra valuta…';

  @override
  String convertFromCurrency(String code) {
    return 'Converti da $code';
  }

  @override
  String get btnUndo => 'Annulla';

  @override
  String get convertSwipeActionsExplanation =>
      'Cambia valuta base, salva un preferito o rimuovi.';

  @override
  String get favoritesSwipeHint =>
      'Scorri a sinistra per rimuovere una coppia salvata.';

  @override
  String currencyRemoved(String code) {
    return '$code rimossa dal tuo elenco';
  }

  @override
  String get expandChartTooltip => 'Visualizza in orizzontale';

  @override
  String get collapseChartTooltip => 'Torna in verticale';

  @override
  String get chartAdLoading => 'Caricamento annuncio…';

  @override
  String get chartAdUnavailable => 'Annuncio non disponibile';

  @override
  String get chartAdInstructions =>
      'Segui le istruzioni dell’annuncio per ottenere il premio';

  @override
  String get dataSummaryRates =>
      'Tassi giornalieri indicativi, non quotazioni in tempo reale. Con Aggiorna all’apertura attivo, l’app controlla i dati alla prima apertura di ogni giorno. Puoi anche aggiornare manualmente. I tassi salvati funzionano offline.';

  @override
  String get rateSourcesTitle => 'Fonti dei dati';

  @override
  String get rateSourcesIntro =>
      'Frankfurter fornisce tassi fiat da banche centrali e altre fonti ufficiali. exchange-api fornisce i dati crypto.';

  @override
  String get chartDataHelpTitle => 'Informazioni sui dati del grafico';
}
