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
  String get tabCharts => 'Charts';

  @override
  String get tabSettings => 'Settings';

  @override
  String get btnSwap => 'Swap';

  @override
  String get btnClear => 'Clear';

  @override
  String get btnRemove => 'Remove';

  @override
  String get btnAdd => 'Add';

  @override
  String get btnDone => 'Done';

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
  String get labelRemoveAds => 'Remove Ads';

  @override
  String get labelDarkMode => 'Dark mode';

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
  String get errorNetworkFailed => 'Network error. Using cached rates.';

  @override
  String get errorNoData => 'No data available';

  @override
  String get msgFavoriteAdded => 'Favorite added';

  @override
  String get msgFavoriteRemoved => 'Favorite removed';
}
