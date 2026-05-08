import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.settings_outlined, size: 64, color: AppTheme.muted),
            SizedBox(height: 16),
            Text(
              'App settings',
              style: TextStyle(fontSize: 18, color: AppTheme.text),
            ),
            SizedBox(height: 8),
            Text(
              'Dark mode · Remove Ads · Preferences',
              style: TextStyle(fontSize: 14, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
