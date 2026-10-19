import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';

class VersionTile extends StatefulWidget {
  const VersionTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  State<VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends State<VersionTile> {
  static const int _requiredTaps = 7;
  static const Duration _tapWindow = Duration(seconds: 4);

  Timer? _tapResetTimer;
  int _tapCount = 0;
  String _appVersion = '--';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = info.version;
    });
  }

  void _handleTap() {
    if (!widget.controller.preferences.devToolsAvailable) return;

    _tapResetTimer?.cancel();
    _tapCount += 1;
    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      widget.controller.toggleDevMode(context);
      return;
    }

    _tapResetTimer = Timer(_tapWindow, () => _tapCount = 0);
    if (_tapCount == _requiredTaps - 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('2 more taps to toggle developer mode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final preferences = widget.controller.preferences;
    final versionTile = SettingsTile(
      title: loc.labelVersion,
      trailing: Text(
        '$_appVersion${preferences.devMode ? ' · DEV' : ''}',
        style: AppTheme.caption.copyWith(color: AppColors.of(context).muted),
      ),
    );

    if (!preferences.devToolsAvailable) return versionTile;
    return GestureDetector(onTap: _handleTap, child: versionTile);
  }
}
