// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Currency Converter';

  @override
  String get tabConvert => 'Convert';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get tabCharts => 'Chart';

  @override
  String get tabSettings => 'Settings';

  @override
  String get btnSwap => 'Swap';

  @override
  String get btnClear => 'Clear';

  @override
  String get btnRemove => 'Remove';

  @override
  String get btnAdd => 'Add currencies';

  @override
  String get btnDone => 'Done';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnBuy => 'Buy';

  @override
  String get btnRefresh => 'Refresh';

  @override
  String get labelFrom => 'From';

  @override
  String get labelTo => 'To';

  @override
  String get labelAmount => 'Amount';

  @override
  String get labelResult => 'Result';

  @override
  String get labelRate => 'Rate';

  @override
  String get labelLastUpdated => 'Last updated';

  @override
  String get labelNoFavorites => 'Pin the pairs you check most';

  @override
  String get labelAddFavorite => 'Add favorite';

  @override
  String get favoritesLocalSubtitle => 'Local pairs saved on this device';

  @override
  String favoritesEmptyBody(Object limit) {
    return 'Swipe left on any currency in Convert and tap Favorite. Up to $limit pairs, free.';
  }

  @override
  String get favoritesOpenConvert => 'Open Convert';

  @override
  String get favoritesLimitMessage =>
      'You can pin up to 3 pairs in this version.';

  @override
  String get favoritesCachedRate => 'Saved daily rate';

  @override
  String get favoritesRateUnavailable => '--';

  @override
  String get removeFavoriteTooltip => 'Remove favorite';

  @override
  String get reorderFavoriteTooltip => 'Reorder favorite';

  @override
  String get openFavoriteTooltip => 'Open pair in Convert';

  @override
  String get favoriteActionPin => 'Favorite';

  @override
  String get favoriteActionSaved => 'Favorited';

  @override
  String get labelRemoveAds => 'Remove ads';

  @override
  String get labelAbout => 'About';

  @override
  String get labelVersion => 'Version';

  @override
  String get labelPrivacy => 'Privacy policy';

  @override
  String get privacyOptionsTitle => 'Privacy options';

  @override
  String get privacyOptionsSubtitle =>
      'Manage advertising consent and privacy choices';

  @override
  String get labelNoAccount => 'No account';

  @override
  String get labelNoCloudSync => 'No cloud sync';

  @override
  String get labelNoAnalytics => 'No analytics';

  @override
  String get labelOfflineMode => 'Offline mode';

  @override
  String get labelCachedRates => 'Cached rates';

  @override
  String get labelConversion => 'Conversion';

  @override
  String get labelData => 'Data';

  @override
  String get labelPremium => 'Premium';

  @override
  String get labelDefaultBaseCurrency => 'Default base currency';

  @override
  String get labelDecimalPlaces => 'Decimal places';

  @override
  String get labelRefreshOnOpen => 'Refresh on open';

  @override
  String get labelRefreshOnOpenSubtitle =>
      'Fetch new rates when the app starts';

  @override
  String get labelClearAllData => 'Clear saved data';

  @override
  String get labelClearAllDataSubtitle =>
      'Rates, chart history and temporary unlocks. Favorites and settings stay.';

  @override
  String get labelRestorePurchases => 'Restore purchases';

  @override
  String get labelRestorePurchasesSubtitle =>
      'Re-check local store purchases on this device';

  @override
  String get premiumUnlocks => 'Premium unlocks';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get oneTimePurchaseNote => 'One-time purchases — no account required.';

  @override
  String get paidUnlocksStay => 'Paid unlocks stay on this device.';

  @override
  String get ownedOnDevice => 'Owned on this device';

  @override
  String get chartsProTitle => 'Charts Pro';

  @override
  String get dataSourcesSubtitle => 'A short overview and your privacy choices';

  @override
  String get versionTapHint => 'Tap 7 times to unlock developer options';

  @override
  String get noRatesTitle => 'No rates yet';

  @override
  String get noRatesSubtitle =>
      'Pull to refresh or tap sync when you are back online';

  @override
  String get dailyRatesTitle => 'Daily exchange rates';

  @override
  String get quickAmounts => 'Quick amounts';

  @override
  String get amountSheetTitle => 'Enter amount';

  @override
  String get selectBaseCurrency => 'Select base currency';

  @override
  String get searchCurrencies => 'Currency, country, or code';

  @override
  String get searchCodeOrName => 'Search code or name';

  @override
  String get addCurrenciesTitle => 'Add currencies';

  @override
  String get conversionLensTitle => 'Conversion Lens';

  @override
  String get staleRateWarning =>
      'Stale rates — values may differ from current market';

  @override
  String get errorNetworkFailed => 'Network error. Using cached rates.';

  @override
  String get errorNoData => 'No data available';

  @override
  String get msgFavoriteAdded => 'Favorite added';

  @override
  String get msgFavoriteRemoved => 'Favorite removed';

  @override
  String get purchasing => 'Purchasing…';

  @override
  String get processingPayment => 'Processing payment…';

  @override
  String get purchaseComplete => 'Purchase complete!';

  @override
  String get purchaseFailed => 'Purchase failed';

  @override
  String get pleaseWait => 'Please wait…';

  @override
  String get tryAgainLater => 'Try again later';

  @override
  String get removingAds => 'Removing ads…';

  @override
  String get unlockingPairs => 'Unlocking all pairs…';

  @override
  String get startingSubscription => 'Starting subscription…';

  @override
  String get adsRemovedForever => 'All ads removed forever';

  @override
  String get allPairsUnlocked => 'All chart pairs unlocked';

  @override
  String get subscriptionActive => 'Subscription active';

  @override
  String get dataDetailsTitle => 'Data & privacy';

  @override
  String get dataPolicyTitle => 'Daily data policy';

  @override
  String get dataPrivacyLine =>
      'Your favorites and settings stay on this device. External services provide rate updates and Google serves ads when enabled.';

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesLine1 =>
      'Rates are indicative daily data, not live prices.';

  @override
  String get updatesLine2 =>
      'With Refresh on open enabled, the app checks once per day when opened.';

  @override
  String get updatesLine3 => 'You can refresh manually anytime.';

  @override
  String get fiatDataTitle => 'Fiat data';

  @override
  String get fiatDataLine1 =>
      'Fiat rates: Frankfurter, based on public central-bank data.';

  @override
  String get fiatDataLine2 =>
      'Fiat charts show up to 2 years of daily history.';

  @override
  String get fiatDataLine3 => 'Saved rates are available offline.';

  @override
  String get cryptoDataTitle => 'Crypto data';

  @override
  String get clearDataTitle => 'Saved data';

  @override
  String get clearDataLine1 =>
      'Clears saved fiat and crypto rates and chart history.';

  @override
  String get clearDataLine2 => 'Also clears temporary chart unlocks.';

  @override
  String get clearDataLine3 => 'Favorites, theme and app settings stay.';

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
  String get refreshRatesTooltip => 'Refresh rates';

  @override
  String get shareRatesTooltip => 'Share rates';

  @override
  String get openSettingsTooltip => 'Settings';

  @override
  String get closeTooltip => 'Close';

  @override
  String get removeCurrencyLabel => 'Remove currency';

  @override
  String get toggleFavoriteLabel => 'Add or remove favorite';

  @override
  String get setAsBaseLabel => 'Set as base currency';

  @override
  String get swapCurrenciesTooltip => 'Swap currencies';

  @override
  String get rateFreshnessInfoLabel => 'Rate freshness info';

  @override
  String get changeChartPairLabel => 'Change chart pair';

  @override
  String changeBaseCurrencyLabel(String code) {
    return 'Change base currency, currently $code';
  }

  @override
  String editAmountLabel(String amount) {
    return 'Edit amount, currently $amount';
  }

  @override
  String openPairLabel(String code) {
    return 'Open $code conversion';
  }

  @override
  String chartRangeLabel(String range) {
    return '$range range';
  }

  @override
  String get cryptoDataSourceLine =>
      'Crypto rates and charts use exchange-api by fawazahmed0.';

  @override
  String get clearDataDialogTitle => 'Clear saved data?';

  @override
  String get snackCacheCleared => 'Cache cleared';

  @override
  String get snackRestoreChecking => 'Checking your purchases…';

  @override
  String get labelThemeMode => 'Theme';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get labelSendFeedback => 'Send feedback';

  @override
  String get sendFeedbackSubtitle =>
      'Questions, ideas or bugs — we read everything';

  @override
  String feedbackEmailSubject(String version) {
    return 'Currency Converter feedback ($version)';
  }

  @override
  String snackNoEmailApp(String email) {
    return 'No email app found — contact us at $email';
  }

  @override
  String favoritesMorePairsHeader(Object effectiveLimit, Object visibleCount) {
    return 'MORE PAIRS · $visibleCount OF $effectiveLimit';
  }

  @override
  String get favoritesAddPairSlot => 'Add a pair';

  @override
  String get favoritesWantMorePairs => 'Want more pairs?';

  @override
  String get favoritesWatchAdPillLabel => 'Watch ad +3';

  @override
  String get favoritesProPillLabel => '16 forever';

  @override
  String get favoritesFirstPairPreview => 'Your first pair shows here';

  @override
  String get convertFromTitle => 'Convert from';

  @override
  String get savedCurrenciesSubtitle => 'Choose a currency from your list';

  @override
  String get addAnotherCurrency => 'Add another currency…';

  @override
  String convertFromCurrency(String code) {
    return 'Convert from $code';
  }

  @override
  String get btnUndo => 'Undo';

  @override
  String get convertSwipeActionsExplanation =>
      'Change base, save a favorite, or remove.';

  @override
  String get favoritesSwipeHint => 'Swipe left to remove a saved pair.';

  @override
  String currencyRemoved(String code) {
    return '$code removed from your list';
  }

  @override
  String get expandChartTooltip => 'View horizontally';

  @override
  String get collapseChartTooltip => 'Return to vertical';

  @override
  String get chartAdLoading => 'Loading ad…';

  @override
  String get chartAdUnavailable => 'Ad unavailable';

  @override
  String get chartAdInstructions =>
      'Follow the ad’s instructions to earn the reward';

  @override
  String get dataSummaryRates =>
      'Indicative daily rates, not live quotes. With Refresh on open enabled, the app checks once per day when opened. You can also refresh manually. Saved rates work offline.';

  @override
  String get rateSourcesTitle => 'Rate sources';

  @override
  String get rateSourcesIntro =>
      'Fiat rates: Frankfurter. Crypto rates: exchange-api.';

  @override
  String get chartDataHelpTitle => 'About chart data';

  @override
  String get labelRateApp => 'Rate the app';

  @override
  String get rateAppSubtitle =>
      'Enjoying it? A rating on Google Play helps a lot';
}
