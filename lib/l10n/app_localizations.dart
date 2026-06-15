import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// App title shown in app switcher
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get appTitle;

  /// Bottom nav label for Convert tab
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get tabConvert;

  /// Bottom nav label for Favorites tab
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// Bottom nav label for Charts tab
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get tabCharts;

  /// Bottom nav label for Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// Swap currencies button
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get btnSwap;

  /// Clear input button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btnClear;

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get btnRemove;

  /// Add currencies button
  ///
  /// In en, this message translates to:
  /// **'Add currencies'**
  String get btnAdd;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// Buy button
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get btnBuy;

  /// Refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get btnRefresh;

  /// From currency label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get labelFrom;

  /// To currency label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get labelTo;

  /// Amount input label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

  /// Conversion result label
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get labelResult;

  /// Exchange rate label
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get labelRate;

  /// Last updated timestamp label
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get labelLastUpdated;

  /// Empty favorites message
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get labelNoFavorites;

  /// Add favorite action label
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get labelAddFavorite;

  /// No description provided for @favoritesLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local pairs saved on this device'**
  String get favoritesLocalSubtitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe left on a currency row in Convert, then tap Pin.'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesOpenConvert.
  ///
  /// In en, this message translates to:
  /// **'Open Convert'**
  String get favoritesOpenConvert;

  /// No description provided for @favoritesLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You can pin up to 3 pairs in this version.'**
  String get favoritesLimitMessage;

  /// No description provided for @favoritesCachedRate.
  ///
  /// In en, this message translates to:
  /// **'Saved daily rate'**
  String get favoritesCachedRate;

  /// No description provided for @favoritesRateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get favoritesRateUnavailable;

  /// No description provided for @removeFavoriteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavoriteTooltip;

  /// No description provided for @openFavoriteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open pair in Convert'**
  String get openFavoriteTooltip;

  /// No description provided for @favoriteActionPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get favoriteActionPin;

  /// No description provided for @favoriteActionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get favoriteActionSaved;

  /// Remove ads in-app purchase label
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get labelRemoveAds;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get labelDarkMode;

  /// Dark mode on subtitle
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get labelDarkModeOn;

  /// Dark mode follows system subtitle
  ///
  /// In en, this message translates to:
  /// **'Follows system'**
  String get labelDarkModeFollowsSystem;

  /// About section label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get labelAbout;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get labelVersion;

  /// Privacy section label
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get labelPrivacy;

  /// No account label
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get labelNoAccount;

  /// No cloud sync label
  ///
  /// In en, this message translates to:
  /// **'No cloud sync'**
  String get labelNoCloudSync;

  /// No analytics label
  ///
  /// In en, this message translates to:
  /// **'No analytics'**
  String get labelNoAnalytics;

  /// Offline mode indicator
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get labelOfflineMode;

  /// Cached rates indicator
  ///
  /// In en, this message translates to:
  /// **'Cached rates'**
  String get labelCachedRates;

  /// Conversion section header in settings
  ///
  /// In en, this message translates to:
  /// **'Conversion'**
  String get labelConversion;

  /// Data section header in settings
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get labelData;

  /// Premium section header in settings
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get labelPremium;

  /// Default base currency setting title
  ///
  /// In en, this message translates to:
  /// **'Default base currency'**
  String get labelDefaultBaseCurrency;

  /// Decimal places setting title
  ///
  /// In en, this message translates to:
  /// **'Decimal places'**
  String get labelDecimalPlaces;

  /// Refresh on open setting title
  ///
  /// In en, this message translates to:
  /// **'Refresh on open'**
  String get labelRefreshOnOpen;

  /// Refresh on open setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Fetch new rates when the app starts'**
  String get labelRefreshOnOpenSubtitle;

  /// Data sources setting title
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get labelDataSources;

  /// Clear data setting title
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get labelClearAllData;

  /// Clear data setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Fiat rates, crypto rates, chart history and temporary unlocks'**
  String get labelClearAllDataSubtitle;

  /// Subscription setting title
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get labelSubscription;

  /// Subscription setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Not available in v1'**
  String get labelSubscriptionSubtitle;

  /// Restore purchases setting title
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get labelRestorePurchases;

  /// Restore purchases setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Re-check local store purchases on this device'**
  String get labelRestorePurchasesSubtitle;

  /// Coming soon badge
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get labelSoon;

  /// Premium unlocks text when not purchased
  ///
  /// In en, this message translates to:
  /// **'Premium unlocks'**
  String get premiumUnlocks;

  /// Premium active text when purchased
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// One-time purchase note
  ///
  /// In en, this message translates to:
  /// **'One-time purchases — no account required.'**
  String get oneTimePurchaseNote;

  /// Paid unlocks stay note
  ///
  /// In en, this message translates to:
  /// **'Paid unlocks stay on this device.'**
  String get paidUnlocksStay;

  /// Owned on device subtitle
  ///
  /// In en, this message translates to:
  /// **'Owned on this device'**
  String get ownedOnDevice;

  /// Charts Pro product title
  ///
  /// In en, this message translates to:
  /// **'Charts Pro'**
  String get chartsProTitle;

  /// Data sources subtitle
  ///
  /// In en, this message translates to:
  /// **'Frankfurter, ECB, crypto sources and chart availability'**
  String get dataSourcesSubtitle;

  /// Developer mode unlock hint
  ///
  /// In en, this message translates to:
  /// **'Tap 7 times to unlock developer options'**
  String get versionTapHint;

  /// No rates error title
  ///
  /// In en, this message translates to:
  /// **'No rates yet'**
  String get noRatesTitle;

  /// No rates error subtitle
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or tap sync when you are back online'**
  String get noRatesSubtitle;

  /// Daily rates info sheet title
  ///
  /// In en, this message translates to:
  /// **'Daily exchange rates'**
  String get dailyRatesTitle;

  /// Quick amount presets label
  ///
  /// In en, this message translates to:
  /// **'Quick amounts'**
  String get quickAmounts;

  /// Amount input sheet title
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get amountSheetTitle;

  /// Base currency picker title
  ///
  /// In en, this message translates to:
  /// **'Select base currency'**
  String get selectBaseCurrency;

  /// Currency search hint
  ///
  /// In en, this message translates to:
  /// **'Currency, country, or code'**
  String get searchCurrencies;

  /// Base currency search hint
  ///
  /// In en, this message translates to:
  /// **'Search code or name'**
  String get searchCodeOrName;

  /// Add currencies picker title
  ///
  /// In en, this message translates to:
  /// **'Add currencies'**
  String get addCurrenciesTitle;

  /// Conversion lens sheet title
  ///
  /// In en, this message translates to:
  /// **'Conversion Lens'**
  String get conversionLensTitle;

  /// Stale rate warning
  ///
  /// In en, this message translates to:
  /// **'Stale rates — values may differ from current market'**
  String get staleRateWarning;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Using cached rates.'**
  String get errorNetworkFailed;

  /// No data error message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get errorNoData;

  /// Favorite added confirmation
  ///
  /// In en, this message translates to:
  /// **'Favorite added'**
  String get msgFavoriteAdded;

  /// Favorite removed confirmation
  ///
  /// In en, this message translates to:
  /// **'Favorite removed'**
  String get msgFavoriteRemoved;

  /// Purchase in progress
  ///
  /// In en, this message translates to:
  /// **'Purchasing…'**
  String get purchasing;

  /// Payment processing status
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get processingPayment;

  /// Purchase success message
  ///
  /// In en, this message translates to:
  /// **'Purchase complete!'**
  String get purchaseComplete;

  /// Purchase failed message
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseFailed;

  /// Please wait status
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pleaseWait;

  /// Try again later message
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get tryAgainLater;

  /// Removing ads status
  ///
  /// In en, this message translates to:
  /// **'Removing ads…'**
  String get removingAds;

  /// Unlocking pairs status
  ///
  /// In en, this message translates to:
  /// **'Unlocking all pairs…'**
  String get unlockingPairs;

  /// Starting subscription status
  ///
  /// In en, this message translates to:
  /// **'Starting subscription…'**
  String get startingSubscription;

  /// Ads removed confirmation
  ///
  /// In en, this message translates to:
  /// **'All ads removed forever'**
  String get adsRemovedForever;

  /// Pairs unlocked confirmation
  ///
  /// In en, this message translates to:
  /// **'All chart pairs unlocked'**
  String get allPairsUnlocked;

  /// Subscription active confirmation
  ///
  /// In en, this message translates to:
  /// **'Subscription active'**
  String get subscriptionActive;

  /// Data details page title
  ///
  /// In en, this message translates to:
  /// **'Data details'**
  String get dataDetailsTitle;

  /// Data policy section title
  ///
  /// In en, this message translates to:
  /// **'Daily data policy'**
  String get dataPolicyTitle;

  /// Privacy intro line
  ///
  /// In en, this message translates to:
  /// **'This app uses exchange-rate data to show conversions and charts. Your data stays on this device.'**
  String get dataPrivacyLine;

  /// Updates section title
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesTitle;

  /// Update frequency line 1
  ///
  /// In en, this message translates to:
  /// **'Rates update at most once per day.'**
  String get updatesLine1;

  /// Update frequency line 2
  ///
  /// In en, this message translates to:
  /// **'Refresh on open only checks for new data when your saved data is old.'**
  String get updatesLine2;

  /// Update frequency line 3
  ///
  /// In en, this message translates to:
  /// **'You can still use manual refresh to request the latest daily update.'**
  String get updatesLine3;

  /// Fiat data section title
  ///
  /// In en, this message translates to:
  /// **'Fiat data'**
  String get fiatDataTitle;

  /// Fiat data line 1
  ///
  /// In en, this message translates to:
  /// **'Fiat rates come from Frankfurter using ECB data.'**
  String get fiatDataLine1;

  /// Fiat data line 2
  ///
  /// In en, this message translates to:
  /// **'Fiat charts can show up to 2 years of daily history.'**
  String get fiatDataLine2;

  /// Fiat data line 3
  ///
  /// In en, this message translates to:
  /// **'If you are offline, the app uses saved data when available.'**
  String get fiatDataLine3;

  /// Crypto data section title
  ///
  /// In en, this message translates to:
  /// **'Crypto data'**
  String get cryptoDataTitle;

  /// Clear data section title
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get clearDataTitle;

  /// Clear data line 1
  ///
  /// In en, this message translates to:
  /// **'Clear all data removes saved rate and chart data from this device.'**
  String get clearDataLine1;

  /// Clear data line 2
  ///
  /// In en, this message translates to:
  /// **'It also removes temporary chart unlocks.'**
  String get clearDataLine2;

  /// Clear data line 3
  ///
  /// In en, this message translates to:
  /// **'It does not remove your theme or normal app settings.'**
  String get clearDataLine3;

  /// No description provided for @favoritesProTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites Pro'**
  String get favoritesProTitle;

  /// No description provided for @favoritesLimitMessageUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Pin up to 3 pairs. Watch an ad or upgrade to add more.'**
  String get favoritesLimitMessageUpgrade;

  /// No description provided for @favoritesPairsHidden.
  ///
  /// In en, this message translates to:
  /// **'{count} pairs hidden'**
  String favoritesPairsHidden(Object count);

  /// No description provided for @favoritesWatchAdToShow.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to see all'**
  String get favoritesWatchAdToShow;

  /// No description provided for @favoritesUnlockForever.
  ///
  /// In en, this message translates to:
  /// **'Unlock 16 pairs forever'**
  String get favoritesUnlockForever;

  /// No description provided for @favoritesLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Favorites limit reached'**
  String get favoritesLimitReached;

  /// No description provided for @favoritesLimitActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve pinned {storedCount} of {freeLimit} free pairs'**
  String favoritesLimitActionSubtitle(Object freeLimit, Object storedCount);

  /// No description provided for @watchAdToAddMore.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to add 3 more'**
  String get watchAdToAddMore;

  /// No description provided for @unlockingFavoritesPro.
  ///
  /// In en, this message translates to:
  /// **'Unlocking Favorites Pro'**
  String get unlockingFavoritesPro;

  /// No description provided for @favoritesProUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Up to 16 favorite pairs unlocked'**
  String get favoritesProUnlocked;

  /// No description provided for @labelDarkModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get labelDarkModeOff;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
