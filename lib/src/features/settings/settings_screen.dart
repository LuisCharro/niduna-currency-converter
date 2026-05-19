import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/settings_tile.dart';
import 'settings_controller.dart';
import 'widgets/base_currency_tile.dart';
import 'widgets/clear_cache_tile.dart';
import 'widgets/decimal_places_tile.dart';
import 'widgets/dev_sandbox_section.dart';
import 'widgets/premium_section.dart';
import 'widgets/section_header.dart';
import 'widgets/switch_tile.dart';
import 'widgets/version_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.monetization,
    required this.preferences,
    required this.onClearCache,
    super.key,
  });

  final MonetizationController monetization;
  final AppPreferences preferences;
  final VoidCallback onClearCache;

  @override
  Widget build(BuildContext context) {
    final controller = SettingsController(
      preferences: preferences,
      monetization: monetization,
      onClearCache: onClearCache,
    );

    return Material(
      color: AppTheme.bg,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([monetization, preferences]),
          builder: (context, _) => Scaffold(
            backgroundColor: AppTheme.bg,
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 118),
              children: <Widget>[
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Conversion'),
                BaseCurrencyTile(controller: controller),
                DecimalPlacesTile(controller: controller),
                SwitchTile(
                  title: 'Dark mode',
                  subtitle: 'Follow system default',
                  value: preferences.isDarkMode,
                  onChanged: controller.toggleDarkMode,
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Data'),
                SwitchTile(
                  title: 'Refresh on open',
                  subtitle: 'Fetch new rates when the app starts',
                  value: preferences.refreshOnOpen,
                  onChanged: controller.toggleRefreshOnOpen,
                ),
                SettingsTile(
                  title: 'Data details',
                  subtitle:
                      'Refresh rules, crypto range limits and cache behavior',
                  onTap: () => controller.openDataDetails(context),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.subtle,
                  ),
                ),
                ClearCacheTile(controller: controller),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                  child: Text(
                    'Fiat and crypto data follow a daily app refresh policy.\nOpen Data details for sources, limits, and cache behavior.',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.subtle,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Premium'),
                PremiumSection(controller: controller),
                const SizedBox(height: 24),
                if (preferences.devMode) ...[
                  const SectionHeader(title: 'Dev Sandbox'),
                  DevSandboxSection(monetization: monetization),
                  const SizedBox(height: 24),
                ],
                const SectionHeader(title: 'About'),
                SettingsTile(
                  title: 'Data sources',
                  subtitle:
                      'Frankfurter, ECB, CoinPaprika and crypto fallback attribution',
                  onTap: () => controller.openDataSources(context),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.subtle,
                  ),
                ),
                VersionTile(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
