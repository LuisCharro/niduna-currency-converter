import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/ads/admob_rewarded_ad_service.dart';
import 'core/ads/ad_consent_manager.dart';
import 'core/monetization/monetization_controller.dart';
import 'core/monetization/play_purchase_service.dart';
import 'core/preferences/app_preferences.dart';
import 'core/rates/provider_config.dart';
import 'core/rates/provider_factory.dart';
import 'core/rates/crypto/crypto_usd_history_cache.dart';
import 'core/rates/crypto/crypto_usd_price_cache.dart';
import 'core/rates/multi_provider_rates_client.dart';
import 'core/rates/rates_service.dart';
import 'core/rates/clients/frankfurter_client.dart';
import 'core/rates/cache/shared_preferences_rates_cache.dart';
import 'features/convert/data/convert_row_hint_store.dart';
import 'features/convert/data/frankfurter_latest_rates_client.dart';
import 'features/convert/data/latest_rates_cache.dart';
import 'features/convert/data/latest_rates_repository.dart';
import 'features/convert/data/multi_provider_latest_rates_repository.dart';
import 'features/convert/presentation/convert_controller.dart';
import 'features/favorites/data/favorites_store.dart';
import 'features/charts/data/rates_service_chart_repository.dart';
import 'features/charts/presentation/charts_controller.dart';
import 'features/settings/settings_controller.dart';

/// Bag of fully-wired services/controllers built once by [AppShell] during
/// startup. Kept as a plain data holder so `app_shell.dart` only needs to
/// assign fields and drive its own [State]/lifecycle logic.
class AppDependencies {
  const AppDependencies({
    required this.preferences,
    required this.localStore,
    required this.rowHintStore,
    required this.controller,
    required this.monetization,
    required this.chartsController,
    required this.settingsController,
  });

  final AppPreferences preferences;
  final FavoritesStore? localStore;
  final ConvertRowHintStore rowHintStore;
  final ConvertController controller;
  final MonetizationController monetization;
  final ChartsController chartsController;
  final SettingsController settingsController;

  /// Builds every service/controller `AppShell` needs on startup.
  ///
  /// [convertRepository] and [favoritesStore] are injected by tests; when
  /// null a real implementation is constructed here. [onClearCache] and
  /// [favoritesLimitProvider] wire back into `AppShell` state.
  static Future<AppDependencies> bootstrap({
    required ConvertRatesRepository? convertRepository,
    required FavoritesStore? favoritesStore,
    required Future<void> Function() onClearCache,
    required int Function() favoritesLimitProvider,
  }) async {
    ProviderConfig.validateReleaseMode();
    // Consent and the ad SDK are initialized in the background so a platform
    // callback cannot hold the app's first frame (or test pump) open.
    unawaited(AdConsentManager.instance.initialize());
    final prefs = await SharedPreferences.getInstance();

    final preferences = AppPreferences(prefs);
    await preferences.migrateCurrencyCodesIfNeeded();

    FavoritesStore? localStore;
    if (favoritesStore == null) {
      localStore = FavoritesStore(prefs);
    }
    final effectiveFavoritesStore = favoritesStore ?? localStore!;
    await effectiveFavoritesStore.seedStarterIfEmpty();

    final repo =
        convertRepository ??
        MultiProviderLatestRatesRepository(
          fiatClient: FrankfurterLatestRatesClient(),
          latestCache: LatestRatesCache(prefs),
          cryptoCache: CryptoUsdPriceCache(prefs),
          cryptoClient: ProviderFactory.createCryptoLatestClient(),
        );

    final rowHintStore = ConvertRowHintStore(prefs);
    final controller = ConvertController(
      repository: repo,
      favoritesStore: effectiveFavoritesStore,
      preferences: preferences,
      defaultBase: preferences.defaultBaseCurrency,
      decimalPlaces: preferences.decimalPlaces,
      selectedCodes: preferences.selectedCodes,
      favoritesLimitProvider: favoritesLimitProvider,
    );
    controller.load();

    final ratesCache = SharedPreferencesRatesCache(prefs);
    final adService = AdMobRewardedAdService();
    late final MonetizationController monetization;
    final purchaseService = PlayPurchaseService(
      onEntitlement: (product) =>
          monetization.applyLifetimeEntitlement(product),
    );
    monetization = MonetizationController(
      prefs,
      adService: adService,
      purchaseService: purchaseService,
    );
    await monetization.loadTempUnlocks();

    final ratesService = RatesService(
      client: MultiProviderRatesClient(
        fiatClient: FrankfurterClient(),
        cryptoHistoryClient: ProviderFactory.createCryptoHistoryClient(),
        cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
      ),
      cache: ratesCache,
    );
    final chartsController = ChartsController(
      repository: RatesServiceChartRepository(ratesService),
      allowCryptoCharts: ProviderConfig.cryptoChartsEnabled,
      defaultBase: preferences.defaultBaseCurrency,
    );
    final settingsController = SettingsController(
      preferences: preferences,
      monetization: monetization,
      adConsent: AdConsentManager.instance,
      onClearCache: onClearCache,
    );

    return AppDependencies(
      preferences: preferences,
      localStore: localStore,
      rowHintStore: rowHintStore,
      controller: controller,
      monetization: monetization,
      chartsController: chartsController,
      settingsController: settingsController,
    );
  }
}
