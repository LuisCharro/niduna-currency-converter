import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/monetization/monetization_controller.dart';
import 'core/monetization/rewarded_ad_service_stub.dart';
import 'core/preferences/app_preferences.dart';
import 'core/rates/provider_config.dart';
import 'core/rates/provider_factory.dart';
import 'core/rates/crypto/crypto_usd_history_cache.dart';
import 'core/rates/crypto/crypto_usd_price_cache.dart';
import 'core/rates/multi_provider_rates_client.dart';
import 'core/rates/rates_service.dart';
import 'core/rates/clients/frankfurter_client.dart';
import 'core/rates/cache/shared_preferences_rates_cache.dart';
import 'core/theme/app_theme.dart';
import 'features/convert/data/frankfurter_latest_rates_client.dart';
import 'features/convert/data/latest_rates_cache.dart';
import 'features/convert/data/latest_rates_repository.dart';
import 'features/convert/data/multi_provider_latest_rates_repository.dart';
import 'features/convert/convert_screen.dart';
import 'features/convert/presentation/convert_controller.dart';
import 'features/favorites/data/favorites_store.dart';
import 'features/charts/charts_screen.dart';
import 'features/charts/presentation/charts_controller.dart';
import 'features/settings/settings_screen.dart';
import 'shared/widgets/floating_pill_nav.dart';

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
      home: AppShell(
        convertRepository: convertRepository,
        favoritesStore: favoritesStore,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({this.convertRepository, this.favoritesStore, super.key});

  final ConvertRatesRepository? convertRepository;
  final FavoritesStore? favoritesStore;

  @override
  State<AppShell> createState() => _AppState();
}

class _AppState extends State<AppShell> {
  int _currentIndex = 0;
  FavoritesStore? _localStore;
  ConvertController? _controller;
  ChartsController? _chartsController;
  MonetizationController? _monetization;
  AppPreferences? _preferences;
  bool _ready = false;

  FavoritesStore get _favoritesStore => widget.favoritesStore ?? _localStore!;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    ProviderConfig.validateReleaseMode();
    final prefs = await SharedPreferences.getInstance();

    _preferences = AppPreferences(prefs);
    _preferences!.addListener(_onPreferencesChanged);

    if (widget.favoritesStore == null) {
      _localStore = FavoritesStore(prefs);
    }

    final repo =
        widget.convertRepository ??
        MultiProviderLatestRatesRepository(
          fiatClient: FrankfurterLatestRatesClient(),
          latestCache: LatestRatesCache(prefs),
          cryptoCache: CryptoUsdPriceCache(prefs),
          cryptoClient: ProviderFactory.createCryptoLatestClient(),
        );

    _controller = ConvertController(
      repository: repo,
      favoritesStore: _favoritesStore,
      preferences: _preferences,
      defaultBase: _preferences!.defaultBaseCurrency,
      decimalPlaces: _preferences!.decimalPlaces,
      selectedCodes: _preferences!.selectedCodes,
    );
    _controller!.load();

    final ratesCache = SharedPreferencesRatesCache(prefs);
    final adService = RewardedAdServiceStub();
    _monetization = MonetizationController(prefs, adService: adService);
    await _monetization!.loadTempUnlocks();
    final ratesService = RatesService(
      client: MultiProviderRatesClient(
        fiatClient: FrankfurterClient(),
        cryptoHistoryClient: ProviderFactory.createCryptoHistoryClient(),
        cryptoHistoryCache: CryptoUsdHistoryCache(prefs),
      ),
      cache: ratesCache,
    );
    _chartsController = ChartsController(
      ratesService: ratesService,
      allowCryptoCharts: ProviderConfig.cryptoChartsEnabled,
      defaultBase: _preferences!.defaultBaseCurrency,
    );

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _preferences?.removeListener(_onPreferencesChanged);
    _localStore?.dispose();
    _controller?.dispose();
    _chartsController?.dispose();
    super.dispose();
  }

  void _onPreferencesChanged() {
    final preferences = _preferences;
    if (preferences == null) return;
    _controller?.setDecimalPlaces(preferences.decimalPlaces);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }
    final screens = <Widget>[
      ConvertScreen(
        controller: _controller!,
        monetization: _monetization!,
        onNavigateToSettings: () => setState(() => _currentIndex = 2),
      ),
      ChartsScreen(
        controller: _chartsController!,
        monetization: _monetization!,
      ),
      SettingsScreen(
        monetization: _monetization!,
        preferences: _preferences!,
        onClearCache: _onClearCache,
      ),
    ];

    return Theme(
      data: _preferences?.isDarkMode == true ? AppTheme.dark : AppTheme.light,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned.fill(child: screens[_currentIndex]),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingPillNav(
                selectedIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onClearCache() async {
    final prefs = _preferences;
    if (prefs == null || _monetization == null) return;
    await prefs.clearAllCaches();
    _monetization!.clearTempUnlocks();
    _controller?.load();
    _chartsController?.load();
  }
}
