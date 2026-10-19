// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Währungsrechner';

  @override
  String get tabConvert => 'Umrechnen';

  @override
  String get tabFavorites => 'Favoriten';

  @override
  String get tabCharts => 'Chart';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get btnSwap => 'Tauschen';

  @override
  String get btnClear => 'Löschen';

  @override
  String get btnRemove => 'Entfernen';

  @override
  String get btnAdd => 'Währungen hinzufügen';

  @override
  String get btnDone => 'Fertig';

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get btnBuy => 'Kaufen';

  @override
  String get btnRefresh => 'Aktualisieren';

  @override
  String get labelFrom => 'Von';

  @override
  String get labelTo => 'Nach';

  @override
  String get labelAmount => 'Betrag';

  @override
  String get labelResult => 'Ergebnis';

  @override
  String get labelRate => 'Kurs';

  @override
  String get labelLastUpdated => 'Zuletzt aktualisiert';

  @override
  String get labelNoFavorites => 'Hefte die Paare an, die du am meisten prüfst';

  @override
  String get labelAddFavorite => 'Favorit hinzufügen';

  @override
  String get favoritesLocalSubtitle => 'Lokale Paare auf diesem Gerät';

  @override
  String favoritesEmptyBody(Object limit) {
    return 'Wische in Umrechnen eine Währung nach links und tippe auf Favorit. Bis zu $limit Paare, kostenlos.';
  }

  @override
  String get favoritesOpenConvert => 'Umrechnen öffnen';

  @override
  String get favoritesLimitMessage =>
      'Du kannst in dieser Version bis zu 3 Paare anheften.';

  @override
  String get favoritesCachedRate => 'Gespeicherter Tageskurs';

  @override
  String get favoritesRateUnavailable => '--';

  @override
  String get removeFavoriteTooltip => 'Favorit entfernen';

  @override
  String get reorderFavoriteTooltip => 'Favorit neu anordnen';

  @override
  String get openFavoriteTooltip => 'Paar in Umrechnen öffnen';

  @override
  String get favoriteActionPin => 'Favorit';

  @override
  String get favoriteActionSaved => 'Favorisiert';

  @override
  String get labelRemoveAds => 'Werbung entfernen';

  @override
  String get labelAbout => 'Info';

  @override
  String get labelVersion => 'Version';

  @override
  String get labelPrivacy => 'Datenschutzerklärung';

  @override
  String get privacyOptionsTitle => 'Datenschutzoptionen';

  @override
  String get privacyOptionsSubtitle =>
      'Werbeeinwilligung und Datenschutzeinstellungen verwalten';

  @override
  String get labelNoAccount => 'Kein Konto';

  @override
  String get labelNoCloudSync => 'Keine Cloud-Synchronisierung';

  @override
  String get labelNoAnalytics => 'Keine Analysen';

  @override
  String get labelOfflineMode => 'Offline-Modus';

  @override
  String get labelCachedRates => 'Zwischengespeicherte Kurse';

  @override
  String get labelConversion => 'Umrechnung';

  @override
  String get labelData => 'Daten';

  @override
  String get labelPremium => 'Premium';

  @override
  String get labelDefaultBaseCurrency => 'Standard-Basiswährung';

  @override
  String get labelDecimalPlaces => 'Dezimalstellen';

  @override
  String get labelRefreshOnOpen => 'Beim Öffnen aktualisieren';

  @override
  String get labelRefreshOnOpenSubtitle =>
      'Neue Kurse beim Start der App abrufen';

  @override
  String get labelClearAllData => 'Gespeicherte Daten löschen';

  @override
  String get labelClearAllDataSubtitle =>
      'Kurse, Chartverlauf und temporäre Freischaltungen. Favoriten und Einstellungen bleiben.';

  @override
  String get labelRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get labelRestorePurchasesSubtitle =>
      'Lokale Store-Käufe auf diesem Gerät erneut prüfen';

  @override
  String get premiumUnlocks => 'Premium-Freischaltungen';

  @override
  String get premiumActive => 'Premium aktiv';

  @override
  String get oneTimePurchaseNote => 'Einmalkäufe; kein Konto erforderlich.';

  @override
  String get paidUnlocksStay =>
      'Bezahlte Freischaltungen bleiben auf diesem Gerät.';

  @override
  String get ownedOnDevice => 'Auf diesem Gerät gekauft';

  @override
  String get chartsProTitle => 'Charts Pro';

  @override
  String get dataSourcesSubtitle =>
      'Ein Überblick und deine Datenschutzoptionen';

  @override
  String get versionTapHint =>
      '7-mal tippen, um Entwickleroptionen freizuschalten';

  @override
  String get noRatesTitle => 'Noch keine Kurse';

  @override
  String get noRatesSubtitle =>
      'Zum Aktualisieren herunterziehen oder auf Synchronisieren tippen, wenn du wieder online bist';

  @override
  String get dailyRatesTitle => 'Tägliche Wechselkurse';

  @override
  String get quickAmounts => 'Schnellbeträge';

  @override
  String get amountSheetTitle => 'Betrag eingeben';

  @override
  String get selectBaseCurrency => 'Basiswährung auswählen';

  @override
  String get searchCurrencies => 'Währung, Land oder Code';

  @override
  String get searchCodeOrName => 'Code oder Name suchen';

  @override
  String get addCurrenciesTitle => 'Währungen hinzufügen';

  @override
  String get conversionLensTitle => 'Umrechnungsansicht';

  @override
  String get staleRateWarning =>
      'Veraltete Kurse — Werte können vom aktuellen Markt abweichen';

  @override
  String get errorNetworkFailed =>
      'Netzwerkfehler. Zwischengespeicherte Kurse werden verwendet.';

  @override
  String get errorNoData => 'Keine Daten verfügbar';

  @override
  String get msgFavoriteAdded => 'Favorit hinzugefügt';

  @override
  String get msgFavoriteRemoved => 'Favorit entfernt';

  @override
  String get purchasing => 'Kauf läuft…';

  @override
  String get processingPayment => 'Zahlung wird verarbeitet…';

  @override
  String get purchaseComplete => 'Kauf abgeschlossen!';

  @override
  String get purchaseFailed => 'Kauf fehlgeschlagen';

  @override
  String get pleaseWait => 'Bitte warten…';

  @override
  String get tryAgainLater => 'Bitte später erneut versuchen';

  @override
  String get removingAds => 'Werbung wird entfernt…';

  @override
  String get unlockingPairs => 'Alle Paare werden freigeschaltet…';

  @override
  String get startingSubscription => 'Abonnement wird gestartet…';

  @override
  String get adsRemovedForever => 'Alle Anzeigen dauerhaft entfernt';

  @override
  String get allPairsUnlocked => 'Alle Chart-Paare freigeschaltet';

  @override
  String get subscriptionActive => 'Abonnement aktiv';

  @override
  String get dataDetailsTitle => 'Daten & Datenschutz';

  @override
  String get dataPolicyTitle => 'Tägliche Datenrichtlinie';

  @override
  String get dataPrivacyLine =>
      'Deine Favoriten und Einstellungen bleiben auf diesem Gerät. Externe Dienste liefern Kurse; Google stellt Werbung bereit, wenn sie aktiviert ist.';

  @override
  String get updatesTitle => 'Aktualisierungen';

  @override
  String get updatesLine1 =>
      'Es sind Richtwerte für Tageskurse, keine Live-Preise.';

  @override
  String get updatesLine2 =>
      'Bei aktivierter Aktualisierung beim Öffnen prüft die App beim ersten Öffnen jedes Tages auf neue Daten.';

  @override
  String get updatesLine3 => 'Du kannst jederzeit manuell aktualisieren.';

  @override
  String get fiatDataTitle => 'Fiat-Daten';

  @override
  String get fiatDataLine1 =>
      'Fiat-Kurse: Frankfurter, basierend auf öffentlichen Zentralbankdaten.';

  @override
  String get fiatDataLine2 =>
      'Fiat-Charts zeigen bis zu 2 Jahre tägliche Historie.';

  @override
  String get fiatDataLine3 => 'Gespeicherte Kurse sind offline verfügbar.';

  @override
  String get cryptoDataTitle => 'Krypto-Daten';

  @override
  String get clearDataTitle => 'Gespeicherte Daten';

  @override
  String get clearDataLine1 =>
      'Löscht gespeicherte Fiat- und Krypto-Kurse sowie den Chartverlauf.';

  @override
  String get clearDataLine2 =>
      'Temporäre Chart-Freischaltungen werden ebenfalls gelöscht.';

  @override
  String get clearDataLine3 =>
      'Favoriten, Theme und App-Einstellungen bleiben erhalten.';

  @override
  String get favoritesProTitle => 'Favorites Pro';

  @override
  String get favoritesLimitMessageUpgrade =>
      'Pin up to 3 pairs. Watch an ad or upgrade to add more.';

  @override
  String favoritesPairsHidden(Object count) {
    return '$count Paare ausgeblendet';
  }

  @override
  String get favoritesWatchAdToShow => 'Werbung ansehen, um alle zu sehen';

  @override
  String get favoritesUnlockForever => '16 Paare dauerhaft freischalten';

  @override
  String get favoritesLimitReached => 'Favorites limit reached';

  @override
  String favoritesLimitActionSubtitle(Object freeLimit, Object storedCount) {
    return 'You\'ve pinned $storedCount of $freeLimit free pairs';
  }

  @override
  String get watchAdToAddMore => 'Werbung ansehen, um 3 weitere hinzuzufügen';

  @override
  String get unlockingFavoritesPro => 'Unlocking Favorites Pro';

  @override
  String get favoritesProUnlocked => 'Up to 16 favorite pairs unlocked';

  @override
  String get refreshRatesTooltip => 'Kurse aktualisieren';

  @override
  String get shareRatesTooltip => 'Kurse teilen';

  @override
  String get openSettingsTooltip => 'Einstellungen';

  @override
  String get closeTooltip => 'Schließen';

  @override
  String get removeCurrencyLabel => 'Währung entfernen';

  @override
  String get toggleFavoriteLabel => 'Favorit hinzufügen oder entfernen';

  @override
  String get setAsBaseLabel => 'Als Basiswährung festlegen';

  @override
  String get swapCurrenciesTooltip => 'Währungen tauschen';

  @override
  String get rateFreshnessInfoLabel => 'Info zur Kursaktualität';

  @override
  String get changeChartPairLabel => 'Diagrammpaar ändern';

  @override
  String changeBaseCurrencyLabel(String code) {
    return 'Basiswährung ändern, aktuell $code';
  }

  @override
  String editAmountLabel(String amount) {
    return 'Betrag bearbeiten, aktuell $amount';
  }

  @override
  String openPairLabel(String code) {
    return '$code-Umrechnung öffnen';
  }

  @override
  String chartRangeLabel(String range) {
    return 'Zeitraum $range';
  }

  @override
  String get cryptoDataSourceLine =>
      'Krypto-Kurse und -Charts: exchange-api von fawazahmed0.';

  @override
  String get clearDataDialogTitle => 'Gespeicherte Daten löschen?';

  @override
  String get snackCacheCleared => 'Cache geleert';

  @override
  String get snackRestoreChecking => 'Käufe werden geprüft …';

  @override
  String get labelThemeMode => 'Theme';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get labelSendFeedback => 'Feedback senden';

  @override
  String get sendFeedbackSubtitle =>
      'Fragen, Ideen oder Fehler — wir lesen alles';

  @override
  String feedbackEmailSubject(String version) {
    return 'Currency Converter Feedback ($version)';
  }

  @override
  String snackNoEmailApp(String email) {
    return 'Keine E-Mail-App gefunden — kontaktieren Sie uns unter $email';
  }

  @override
  String favoritesMorePairsHeader(Object effectiveLimit, Object visibleCount) {
    return 'WEITERE PAARE · $visibleCount VON $effectiveLimit';
  }

  @override
  String get favoritesAddPairSlot => 'Paar hinzufügen';

  @override
  String get favoritesWantMorePairs => 'Mehr Paare gewünscht?';

  @override
  String get favoritesWatchAdPillLabel => 'Werbung +3';

  @override
  String get favoritesProPillLabel => '16 für immer';

  @override
  String get favoritesFirstPairPreview => 'Dein erstes Paar erscheint hier';

  @override
  String get convertFromTitle => 'Umrechnen von';

  @override
  String get savedCurrenciesSubtitle => 'Wähle eine Währung aus deiner Liste';

  @override
  String get addAnotherCurrency => 'Weitere Währung hinzufügen…';

  @override
  String convertFromCurrency(String code) {
    return 'Von $code umrechnen';
  }

  @override
  String get btnUndo => 'Rückgängig';

  @override
  String get convertSwipeActionsExplanation =>
      'Basiswährung ändern, Favorit speichern oder entfernen.';

  @override
  String get favoritesSwipeHint =>
      'Wische nach links, um ein gespeichertes Paar zu entfernen.';

  @override
  String currencyRemoved(String code) {
    return '$code aus deiner Liste entfernt';
  }

  @override
  String get expandChartTooltip => 'Im Querformat anzeigen';

  @override
  String get collapseChartTooltip => 'Zurück zum Hochformat';

  @override
  String get chartAdLoading => 'Werbung wird geladen…';

  @override
  String get chartAdUnavailable => 'Werbung nicht verfügbar';

  @override
  String get chartAdInstructions =>
      'Folge den Anweisungen der Werbung, um die Belohnung zu erhalten';

  @override
  String get dataSummaryRates =>
      'Ungefähre Tageskurse, keine Live-Kurse. Bei aktiviertem Aktualisieren beim Öffnen prüft die App beim ersten Öffnen des Tages auf neue Daten. Du kannst auch manuell aktualisieren. Gespeicherte Kurse funktionieren offline.';

  @override
  String get rateSourcesTitle => 'Kursquellen';

  @override
  String get rateSourcesIntro =>
      'Fiat-Kurse: Frankfurter. Kryptokurse: exchange-api.';

  @override
  String get chartDataHelpTitle => 'Über die Chartdaten';
}
