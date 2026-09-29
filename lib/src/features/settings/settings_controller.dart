import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/ads/ad_consent_manager.dart';
import '../../core/monetization/purchase_service.dart';
import '../../core/preferences/app_preferences.dart';
import '../../../l10n/app_localizations_safe.dart';
import 'settings_links.dart';
import 'widgets/clear_cache_dialog.dart';
import 'widgets/data_details_page.dart';
import 'widgets/iap_purchase_player.dart';
import 'widgets/settings_detail_route.dart';

class SettingsController extends ChangeNotifier {
  static const String feedbackEmailAddress = SettingsLinks.feedbackEmailAddress;

  SettingsController({
    required this.preferences,
    required this.monetization,
    required this.onClearCache,
    AdConsentManager? adConsent,
    SettingsLinks? links,
  }) : adConsent = adConsent ?? AdConsentManager.instance,
       _links = links ?? const SettingsLinks();

  final AppPreferences preferences;
  final MonetizationController monetization;
  final AdConsentManager adConsent;
  final VoidCallback onClearCache;
  final SettingsLinks _links;

  Future<void> pickBaseCurrency(BuildContext context, String selected) async {
    preferences.setDefaultBaseCurrency(selected);
  }

  void setDecimalPlaces(int value) => preferences.setDecimalPlaces(value);

  void toggleRefreshOnOpen(bool value) => preferences.setRefreshOnOpen(value);

  void setThemeMode(AppThemeMode mode) => preferences.setThemeMode(mode);

  void openDataDetails(BuildContext context) {
    final theme = Theme.of(context);
    Navigator.of(context).push(
      buildSettingsDetailRoute<void>(
        theme: theme,
        builder: (_) => const DataDetailsPage(),
      ),
    );
  }

  Future<void> openPrivacyPolicy() => _links.openPrivacyPolicy();

  Future<void> sendFeedback(BuildContext context, String appVersion) =>
      _links.sendFeedback(context, appVersion);

  Future<void> openPrivacyOptions() => adConsent.showPrivacyOptions();

  void requestClearCache(BuildContext context) =>
      showClearCacheDialog(context, onConfirm: onClearCache);

  void toggleDevMode(BuildContext context) {
    if (!preferences.devToolsAvailable) return;
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n(context).snackRestoreChecking)));
    monetization.restorePurchases();
  }
}
