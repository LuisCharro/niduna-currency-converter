import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/purchase_service.dart';
import '../../core/preferences/app_preferences.dart';
import 'widgets/data_details_page.dart';
import 'widgets/data_sources_page.dart';
import 'widgets/iap_purchase_player.dart';
import 'widgets/settings_detail_route.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    required this.preferences,
    required this.monetization,
    required this.onClearCache,
  });

  final AppPreferences preferences;
  final MonetizationController monetization;
  final VoidCallback onClearCache;

  Future<void> pickBaseCurrency(BuildContext context, String selected) async {
    preferences.setDefaultBaseCurrency(selected);
  }

  void setDecimalPlaces(int value) => preferences.setDecimalPlaces(value);

  void toggleRefreshOnOpen(bool value) => preferences.setRefreshOnOpen(value);

  void toggleDarkMode(bool value) => preferences.setDarkMode(value);

  void openDataDetails(BuildContext context) {
    final theme = Theme.of(context);
    Navigator.of(context).push(
      buildSettingsDetailRoute<void>(
        theme: theme,
        builder: (_) => const DataDetailsPage(),
      ),
    );
  }

  void openDataSources(BuildContext context) {
    final theme = Theme.of(context);
    Navigator.of(context).push(
      buildSettingsDetailRoute<void>(
        theme: theme,
        builder: (_) => const DataSourcesPage(),
      ),
    );
  }

  void requestClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will clear latest fiat rates, latest crypto rates, chart history, crypto chart history, and all temporary pair unlocks.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onClearCache();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
            child: Text('Clear', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void toggleDevMode(BuildContext context) {
    final current = preferences.devMode;
    final next = !current;
    preferences.setDevMode(next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(next ? 'Dev Mode enabled' : 'Dev Mode disabled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void purchaseProduct(BuildContext context, ProductType product) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => IapPurchasePlayer(
          controller: monetization,
          product: product,
          onResult: (success) => Navigator.of(context).pop(success),
        ),
      ),
    );
  }

  void restorePurchases(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore purchases coming soon!')),
    );
  }
}
