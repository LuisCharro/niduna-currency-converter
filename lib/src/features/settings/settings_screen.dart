import 'package:flutter/material.dart';

import '../../core/currency/supported_currencies.dart';
import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/purchase_service.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/currency_flag_icon.dart';
import 'widgets/iap_purchase_player.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: Listenable.merge([monetization, preferences]),
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: <Widget>[
        _SectionHeader(title: 'Conversion'),
        const SizedBox(height: 8),
        _DefaultBaseTile(preferences: preferences),
        const SizedBox(height: 10),
        _DecimalPlacesTile(preferences: preferences),
        const SizedBox(height: 10),
        _DarkModeTile(preferences: preferences),
        const SizedBox(height: 20),
        _SectionHeader(title: 'Data'),
        const SizedBox(height: 8),
        _RefreshOnOpenTile(preferences: preferences),
        const SizedBox(height: 10),
        _ClearCacheTile(onClearCache: onClearCache),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          child: Text(
            'Rates are fetched once daily from the European Central Bank.\nData may be up to 24 hours old.',
            style: TextStyle(fontSize: 11, color: AppTheme.subtle, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeader(title: '💎 Premium'),
        const SizedBox(height: 8),
        _PremiumSection(monetization: monetization),
        const SizedBox(height: 20),
        if (preferences.devMode) ...[
          _SectionHeader(title: 'Dev Sandbox'),
          const SizedBox(height: 8),
          _DevSandboxSection(monetization: monetization),
          const SizedBox(height: 20),
        ],
        _SectionHeader(title: 'About'),
        const SizedBox(height: 8),
        _VersionTile(preferences: preferences),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.muted,
        letterSpacing: .5,
      ),
    );
  }
}

class _DefaultBaseTile extends StatelessWidget {
  const _DefaultBaseTile({required this.preferences});
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(preferences.defaultBaseCurrency);
    return _SettingsTile(
      title: 'Default base currency',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${currency.symbol} ${currency.code}',
            style: TextStyle(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppTheme.subtle, size: 20),
        ],
      ),
      onTap: () => _showBasePicker(context),
    );
  }

  void _showBasePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.card,
      builder: (_) => SafeArea(
        top: false,
        child: _BaseCurrencyPicker(
          currentBase: preferences.defaultBaseCurrency,
        ),
      ),
    );
    if (selected != null) {
      preferences.setDefaultBaseCurrency(selected);
    }
  }
}

class _BaseCurrencyPicker extends StatefulWidget {
  const _BaseCurrencyPicker({required this.currentBase});
  final String currentBase;

  @override
  State<_BaseCurrencyPicker> createState() => _BaseCurrencyPickerState();
}

class _BaseCurrencyPickerState extends State<_BaseCurrencyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final currencies = supportedCurrencies.where((c) {
      if (_query.isEmpty) return true;
      return c.code.toUpperCase().contains(_query) ||
          c.name.toUpperCase().contains(_query);
    }).toList();

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
            child: Row(
              children: <Widget>[
                const Text('Select base currency',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: AppTheme.muted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toUpperCase()),
              decoration: InputDecoration(
                hintText: 'Search code or name',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                fillColor: AppTheme.container.withValues(alpha: .55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: currencies.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.border),
              itemBuilder: (_, i) {
                final c = currencies[i];
                final selected = c.code == widget.currentBase;
                return ListTile(
                  onTap: selected ? null : () => Navigator.of(context).pop(c.code),
                  leading: CurrencyFlagIcon(
                    code: c.code,
                    symbol: c.symbol,
                    radius: 16,
                  ),
                  title: Text(c.code,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected ? AppTheme.muted : AppTheme.text)),
                  subtitle: Text(c.name),
                  trailing: selected
                      ? Icon(Icons.check_circle, color: AppTheme.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DecimalPlacesTile extends StatelessWidget {
  const _DecimalPlacesTile({required this.preferences});
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: 'Decimal places',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppPreferences.supportedDecimalPlaces.map((v) {
          final selected = v == preferences.decimalPlaces;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              onTap: () => preferences.setDecimalPlaces(v),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.container,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$v',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppTheme.text,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RefreshOnOpenTile extends StatelessWidget {
  const _RefreshOnOpenTile({required this.preferences});
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: 'Refresh on open',
      subtitle: 'Fetch new rates when the app starts',
      trailing: Switch(
        value: preferences.refreshOnOpen,
        onChanged: preferences.setRefreshOnOpen,
        activeTrackColor: AppTheme.primary,
      ),
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  const _DarkModeTile({required this.preferences});
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: 'Dark mode',
      subtitle: 'Follow system default',
      trailing: Switch(
        value: preferences.isDarkMode,
        onChanged: (v) => preferences.setDarkMode(v),
        activeTrackColor: AppTheme.primary,
      ),
    );
  }
}

class _ClearCacheTile extends StatelessWidget {
  const _ClearCacheTile({required this.onClearCache});
  final VoidCallback onClearCache;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: 'Clear all data',
      subtitle: 'Rates cache, chart cache and temporary unlocks',
      trailing: InkWell(
        onTap: () => _confirmClear(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.container,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            'Clear',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.text,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Clear all data?'),
        content: const Text(
            'This will clear rates cache, chart cache, and all temporary pair unlocks.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onClearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }
}

class _VersionTile extends StatefulWidget {
  const _VersionTile({required this.preferences});
  final AppPreferences preferences;

  @override
  State<_VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends State<_VersionTile> {
  bool _devModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _devModeEnabled = widget.preferences.devMode;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _devModeEnabled = !_devModeEnabled;
          widget.preferences.setDevMode(_devModeEnabled);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_devModeEnabled
                ? 'Dev Mode enabled'
                : 'Dev Mode disabled'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: _SettingsTile(
        title: 'Version',
        trailing: Text(
          '1.0.0${_devModeEnabled ? ' · DEV' : ''}',
          style: TextStyle(fontSize: 14, color: AppTheme.muted),
        ),
      ),
    );
  }
}

class _DevSandboxSection extends StatelessWidget {
  const _DevSandboxSection({required this.monetization});
  final MonetizationController monetization;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _EntitlementSwitch(
          label: 'Subscription active',
          description: 'Unlocks all premium features and removes ads',
          value: monetization.hasActiveSubscription,
          onChanged: monetization.setSubscriptionActive,
        ),
        const SizedBox(height: 8),
        _EntitlementSwitch(
          label: 'Remove Ads lifetime',
          description: 'Hides ads when no subscription is active',
          value: monetization.hasRemoveAdsLifetime,
          onChanged: monetization.setRemoveAdsLifetime,
        ),
        const SizedBox(height: 8),
        _EntitlementSwitch(
          label: 'Charts Pro lifetime',
          description: 'Unlocks any chart pair without subscription',
          value: monetization.hasChartsProLifetime,
          onChanged: monetization.setChartsProLifetime,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.container.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                monetization.adsEnabled ? Icons.visibility : Icons.visibility_off,
                size: 16,
                color: AppTheme.muted,
              ),
              const SizedBox(width: 8),
              Text(
                monetization.adsEnabled ? 'Ads: visible' : 'Ads: hidden',
                style: TextStyle(fontSize: 13, color: AppTheme.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EntitlementSwitch extends StatelessWidget {
  const _EntitlementSwitch({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label,
                    style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: AppTheme.primary),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _PremiumSection extends StatelessWidget {
  const _PremiumSection({required this.monetization});
  final MonetizationController monetization;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SubscriptionCard(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: <Widget>[
              Expanded(child: Divider(color: AppTheme.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('or buy separately',
                    style: TextStyle(fontSize: 11, color: AppTheme.subtle)),
              ),
              Expanded(child: Divider(color: AppTheme.border)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _PremiumCard(
          icon: Icons.visibility_off,
          title: 'Remove Ads',
          description: 'Enjoy the app without any advertisements',
          price: '1.99 CHF',
          owned: monetization.hasRemoveAdsLifetime,
          onBuy: () => _purchase(context, ProductType.removeAds),
        ),
        const SizedBox(height: 10),
        _PremiumCard(
          icon: Icons.diamond_outlined,
          title: 'Unlock All Pairs',
          description: 'Select any currency pair in Charts — forever',
          price: '2.99 CHF',
          owned: monetization.hasChartsProLifetime,
          onBuy: () => _purchase(context, ProductType.chartsPro),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _restorePurchases(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                'Restore Purchases',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _purchase(BuildContext context, ProductType product) {
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

  void _restorePurchases(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore purchases coming soon!')),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
    required this.owned,
    required this.onBuy,
  });

  final IconData icon;
  final String title;
  final String description;
  final String price;
  final bool owned;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: owned ? Colors.green.shade400 : AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(title,
                        style:
                            const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    if (!owned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('in Subscription',
                            style:
                                TextStyle(fontSize: 9, color: AppTheme.primary)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
              ],
            ),
          ),
          if (owned)
            Icon(Icons.check_circle, size: 20, color: Colors.green.shade400)
          else ...[
            GestureDetector(
              onTap: onBuy,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.primary.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.workspace_premium_outlined,
                  size: 22, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Premium Subscription',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.container.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text('Coming Soon',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.subtle)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('All features included',
              style: TextStyle(fontSize: 13, color: AppTheme.text)),
          const SizedBox(height: 6),
          _SubFeatureRow(Icons.visibility_off, 'Remove ads'),
          _SubFeatureRow(Icons.diamond_outlined, 'Unlock all chart pairs'),
          _SubFeatureRow(Icons.show_chart, 'Intraday ranges (1H/6H/1D)'),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Icon(Icons.construction, size: 11, color: AppTheme.subtle),
              const SizedBox(width: 4),
              Flexible(
                child: Text('1 week free trial, then X.XX CHF/year',
                    style: TextStyle(fontSize: 11, color: AppTheme.subtle)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubFeatureRow extends StatelessWidget {
  const _SubFeatureRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 14, color: AppTheme.muted),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
        ],
      ),
    );
  }
}