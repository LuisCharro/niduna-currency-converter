import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/convert/data/latest_rates_repository.dart';
import 'features/convert/convert_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/charts/charts_screen.dart';
import 'features/settings/settings_screen.dart';

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({this.convertRepository, super.key});

  final ConvertRatesRepository? convertRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: AppTheme.light,
      home: AppShell(convertRepository: convertRepository),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({this.convertRepository, super.key});

  final ConvertRatesRepository? convertRepository;

  @override
  State<AppShell> createState() => _AppState();
}

class _AppState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      ConvertScreen(repository: widget.convertRepository),
      const FavoritesScreen(),
      const ChartsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.muted,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Convert',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
