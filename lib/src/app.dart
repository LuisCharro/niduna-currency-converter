import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/monetization/monetization_controller.dart';
import 'core/monetization/rewarded_ad_service_stub.dart';
import 'core/preferences/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/rates/rates_service.dart';
import 'core/rates/clients/frankfurter_client.dart';
import 'core/rates/cache/shared_preferences_rates_cache.dart';
import 'features/convert/data/frankfurter_latest_rates_client.dart';
import 'features/convert/data/latest_rates_cache.dart';
import 'features/convert/data/latest_rates_repository.dart';
import 'features/convert/convert_screen.dart';
import 'features/convert/presentation/convert_controller.dart';
import 'features/favorites/data/favorites_store.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/charts/charts_screen.dart';
import 'features/charts/presentation/charts_controller.dart';
import 'features/settings/settings_screen.dart';

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
  const AppShell({
    this.convertRepository,
    this.favoritesStore,
    super.key,
  });

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

  FavoritesStore get _favoritesStore =>
      widget.favoritesStore ?? _localStore!;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    final prefs = await SharedPreferences.getInstance();

    _preferences = AppPreferences(prefs);

    if (widget.favoritesStore == null) {
      _localStore = FavoritesStore(prefs);
    }

    final repo = widget.convertRepository ??
        LatestRatesRepository(
          client: FrankfurterLatestRatesClient(),
          cache: LatestRatesCache(prefs),
        );

    _controller = ConvertController(
      repository: repo,
      favoritesStore: _favoritesStore,
      defaultBase: _preferences!.defaultBaseCurrency,
    );
    _controller!.load();

    final ratesCache = SharedPreferencesRatesCache(prefs);
    final adService = RewardedAdServiceStub();
    _monetization = MonetizationController(prefs, adService: adService);
    await _monetization!.loadTempUnlocks();
    final ratesService = RatesService(
      client: FrankfurterClient(),
      cache: ratesCache,
    );
    _chartsController = ChartsController(
      ratesService: ratesService,
      defaultBase: _preferences!.defaultBaseCurrency,
    );

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _localStore?.dispose();
    _controller?.dispose();
    _chartsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }
    final screens = <Widget>[
      ConvertScreen(controller: _controller!, monetization: _monetization!),
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
        body: screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.muted,
          onTap: (index) => setState(() => _currentIndex = index),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: 'Convert',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Charts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToConvert(String base, String quote) {
    if (_controller != null && base.isNotEmpty) {
      _controller!.setBase(base);
      if (quote.isNotEmpty && !_controller!.state.selectedCodes.contains(quote)) {
        _controller!.toggleCode(quote);
      }
    }
    setState(() => _currentIndex = 0);
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
