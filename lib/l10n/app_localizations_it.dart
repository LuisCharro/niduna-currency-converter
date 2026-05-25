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
  String get labelNoFavorites => 'Nessun preferito';

  @override
  String get labelAddFavorite => 'Aggiungi preferito';

  @override
  String get favoritesLocalSubtitle =>
      'Coppie locali salvate su questo dispositivo';

  @override
  String get favoritesEmptyBody =>
      'Scorri a sinistra su una riga valuta in Converti, poi tocca Fissa.';

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
  String get openFavoriteTooltip => 'Apri coppia in Converti';

  @override
  String get favoriteActionPin => 'Fissa';

  @override
  String get favoriteActionSaved => 'Fissata';

  @override
  String get labelRemoveAds => 'Rimuovi annunci';

  @override
  String get labelDarkMode => 'Modalità scura';

  @override
  String get labelDarkModeOn => 'Attiva';

  @override
  String get labelDarkModeFollowsSystem => 'Segui sistema';

  @override
  String get labelAbout => 'Informazioni';

  @override
  String get labelVersion => 'Versione';

  @override
  String get labelPrivacy => 'Privacy';

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
  String get labelDataSources => 'Fonti dati';

  @override
  String get labelClearAllData => 'Cancella tutti i dati';

  @override
  String get labelClearAllDataSubtitle =>
      'Tassi fiat, tassi crypto, cronologia grafici e sblocchi temporanei';

  @override
  String get labelSubscription => 'Abbonamento';

  @override
  String get labelSubscriptionSubtitle => 'Non disponibile in v1';

  @override
  String get labelRestorePurchases => 'Ripristina acquisti';

  @override
  String get labelRestorePurchasesSubtitle =>
      'Ricontrolla gli acquisti locali su questo dispositivo';

  @override
  String get labelSoon => 'Prossimamente';

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
      'Frankfurter, BCE, fonti crypto e disponibilità dei grafici';

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
  String get dataDetailsTitle => 'Dettagli dei dati';

  @override
  String get dataPolicyTitle => 'Politica giornaliera dei dati';

  @override
  String get dataPrivacyLine =>
      'Questa app usa dati sui tassi di cambio per mostrare conversioni e grafici. I tuoi dati restano su questo dispositivo.';

  @override
  String get updatesTitle => 'Aggiornamenti';

  @override
  String get updatesLine1 =>
      'I tassi si aggiornano al massimo una volta al giorno.';

  @override
  String get updatesLine2 =>
      'Aggiorna all\'apertura controlla nuovi dati solo quando quelli salvati sono vecchi.';

  @override
  String get updatesLine3 =>
      'Puoi comunque usare l\'aggiornamento manuale per richiedere l\'ultimo aggiornamento giornaliero.';

  @override
  String get fiatDataTitle => 'Dati fiat';

  @override
  String get fiatDataLine1 =>
      'I tassi fiat provengono da Frankfurter usando dati BCE.';

  @override
  String get fiatDataLine2 =>
      'I grafici fiat possono mostrare fino a 2 anni di storico giornaliero.';

  @override
  String get fiatDataLine3 =>
      'Se sei offline, l\'app usa i dati salvati quando disponibili.';

  @override
  String get cryptoDataTitle => 'Dati crypto';

  @override
  String get clearDataTitle => 'Cancella dati';

  @override
  String get clearDataLine1 =>
      'Cancella tutti i dati rimuove da questo dispositivo i tassi e la cronologia grafici salvati.';

  @override
  String get clearDataLine2 =>
      'Rimuove anche gli sblocchi temporanei dei grafici.';

  @override
  String get clearDataLine3 =>
      'Non rimuove il tema né le normali impostazioni dell\'app.';
}
