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
  String get labelNoFavorites => 'No favorites yet';

  @override
  String get labelAddFavorite => 'Add favorite';

  @override
  String get labelRemoveAds => 'Remove ads';

  @override
  String get labelDarkMode => 'Dark mode';

  @override
  String get labelDarkModeOn => 'On';

  @override
  String get labelDarkModeFollowsSystem => 'Follows system';

  @override
  String get labelAbout => 'About';

  @override
  String get labelVersion => 'Version';

  @override
  String get labelPrivacy => 'Privacy';

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
  String get labelDataSources => 'Data sources';

  @override
  String get labelClearAllData => 'Clear all data';

  @override
  String get labelClearAllDataSubtitle =>
      'Fiat rates, crypto rates, chart history and temporary unlocks';

  @override
  String get labelSubscription => 'Subscription';

  @override
  String get labelSubscriptionSubtitle => 'Not available in v1';

  @override
  String get labelRestorePurchases => 'Restore purchases';

  @override
  String get labelRestorePurchasesSubtitle =>
      'Re-check local store purchases on this device';

  @override
  String get labelSoon => 'Coming Soon';

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
  String get dataSourcesSubtitle =>
      'Frankfurter, ECB, crypto sources and chart availability';

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
  String get dataDetailsTitle => 'Data details';

  @override
  String get dataPolicyTitle => 'Daily data policy';

  @override
  String get dataPrivacyLine =>
      'This app uses exchange-rate data to show conversions and charts. Your data stays on this device.';

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesLine1 => 'Rates update at most once per day.';

  @override
  String get updatesLine2 =>
      'Refresh on open only checks for new data when your saved data is old.';

  @override
  String get updatesLine3 =>
      'You can still use manual refresh to request the latest daily update.';

  @override
  String get fiatDataTitle => 'Fiat data';

  @override
  String get fiatDataLine1 =>
      'Fiat rates come from Frankfurter using ECB data.';

  @override
  String get fiatDataLine2 =>
      'Fiat charts can show up to 2 years of daily history.';

  @override
  String get fiatDataLine3 =>
      'If you are offline, the app uses saved data when available.';

  @override
  String get cryptoDataTitle => 'Crypto data';

  @override
  String get clearDataTitle => 'Clear data';

  @override
  String get clearDataLine1 =>
      'Clear all data removes saved rate and chart data from this device.';

  @override
  String get clearDataLine2 => 'It also removes temporary chart unlocks.';

  @override
  String get clearDataLine3 =>
      'It does not remove your theme or normal app settings.';
}
