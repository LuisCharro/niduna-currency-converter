import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_dependencies.dart';
import 'core/monetization/monetization_controller.dart';
import 'core/preferences/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/convert/data/convert_row_hint_store.dart';
import 'features/convert/data/latest_rates_repository.dart';
import 'features/convert/convert_screen.dart';
import 'features/convert/presentation/convert_controller.dart';
import 'features/favorites/data/favorites_store.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/charts/charts_screen.dart';
import 'features/charts/presentation/charts_controller.dart';
import 'features/settings/settings_controller.dart';
import 'features/settings/settings_screen.dart';
import 'shared/widgets/fade_slide_switcher.dart';
import 'shared/widgets/floating_pill_nav.dart';

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
  ConvertRowHintStore? _rowHintStore;
  ChartsController? _chartsController;
  SettingsController? _settingsController;
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
    final deps = await AppDependencies.bootstrap(
      convertRepository: widget.convertRepository,
      favoritesStore: widget.favoritesStore,
      onClearCache: _onClearCache,
      favoritesLimitProvider: () => _monetization?.favoritesEffectiveLimit ?? 3,
    );

    _preferences = deps.preferences;
    _preferences!.addListener(_onPreferencesChanged);
    _localStore = deps.localStore;
    _rowHintStore = deps.rowHintStore;
    _controller = deps.controller;
    _monetization = deps.monetization;
    _chartsController = deps.chartsController;
    _settingsController = deps.settingsController;

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
    _settingsController?.dispose();
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
        onNavigateToSettings: () => setState(() => _currentIndex = 3),
        hintStore: _rowHintStore,
      ),
      FavoritesScreen(
        favoritesStore: _favoritesStore,
        controller: _controller!,
        monetization: _monetization!,
        onNavigateToConvert: (_, _) => setState(() => _currentIndex = 0),
      ),
      ChartsScreen(
        controller: _chartsController!,
        monetization: _monetization!,
      ),
      SettingsScreen(
        controller: _settingsController!,
        preferences: _preferences!,
      ),
    ];

    final theme = AppTheme.themeFor(_effectiveIsDark(context));
    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemOverlayFor(theme.brightness),
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: FadeSlideSwitcher(
                  switcherKey: const Key('shell_tab_transition'),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: screens[_currentIndex],
                  ),
                ),
              ),
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
      ),
    );
  }

  bool _effectiveIsDark(BuildContext context) {
    switch (_preferences?.themeMode ?? AppThemeMode.system) {
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
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
