import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_theme.dart';
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
  static const Duration _holdDuration = Duration(seconds: 10);

  Timer? _tapResetTimer;
  Timer? _holdTimer;
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
    _holdTimer?.cancel();
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

  void _startHoldUnlock() {
    _holdTimer?.cancel();
    _holdTimer = Timer(_holdDuration, () {
      if (!mounted) return;
      _holdTimer = null;
      _tapCount = 0;
      widget.controller.toggleDevMode(context);
    });
  }

  void _cancelHoldUnlock() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final devModeEnabled = widget.controller.preferences.devMode;
    return GestureDetector(
      onTap: _handleTap,
      onLongPressStart: (_) => _startHoldUnlock(),
      onLongPressEnd: (_) => _cancelHoldUnlock(),
      child: SettingsTile(
        title: 'Version',
        trailing: Text(
          '$_appVersion${devModeEnabled ? ' · DEV' : ''}',
          style: AppTheme.caption.copyWith(color: AppTheme.muted),
        ),
      ),
    );
  }
}
