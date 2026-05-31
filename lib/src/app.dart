import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'core/theme/app_theme.dart';
import 'features/convert/data/latest_rates_repository.dart';
import 'features/favorites/data/favorites_store.dart';
import 'app_shell.dart';
import '../../l10n/app_localizations.dart';

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({
    this.convertRepository,
    this.favoritesStore,
    super.key,
  });

  final ConvertRatesRepository? convertRepository;
  final FavoritesStore? favoritesStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        final preferred = locales?.first;
        Locale resolved = supportedLocales.first;

        if (preferred != null) {
          resolved = supportedLocales.firstWhere(
            (locale) => locale.languageCode == preferred.languageCode,
            orElse: () => supportedLocales.first,
          );
        }

        intl.Intl.defaultLocale = resolved.languageCode;
        return resolved;
      },
      home: AppShell(
        convertRepository: convertRepository,
        favoritesStore: favoritesStore,
      ),
    );
  }
}
