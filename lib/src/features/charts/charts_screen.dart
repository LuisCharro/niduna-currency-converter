import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charts')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.show_chart, size: 64, color: AppTheme.muted),
            SizedBox(height: 16),
            Text(
              'Historical rate charts',
              style: TextStyle(fontSize: 18, color: AppTheme.text),
            ),
            SizedBox(height: 8),
            Text(
              'Up to 2 years, daily data',
              style: TextStyle(fontSize: 14, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
