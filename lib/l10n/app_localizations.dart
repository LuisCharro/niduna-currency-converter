import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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
  /// **'Charts'**
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

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btnAdd;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

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

  /// Remove ads in-app purchase label
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get labelRemoveAds;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get labelDarkMode;

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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
