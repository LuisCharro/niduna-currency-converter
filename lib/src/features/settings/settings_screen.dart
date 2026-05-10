import 'package:flutter/material.dart';

import '../../core/currency/supported_currencies.dart';
import '../../core/monetization/monetization_controller.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/theme/app_theme.dart';

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
        const SizedBox(height: 20),
        _SectionHeader(title: 'Data'),
        const SizedBox(height: 8),
        _RefreshOnOpenTile(preferences: preferences),
        const SizedBox(height: 10),
        _ClearCacheTile(onClearCache: onClearCache),
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
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.container,
                    child: Text(c.symbol, style: const TextStyle(fontSize: 14)),
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