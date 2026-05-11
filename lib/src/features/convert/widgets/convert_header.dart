import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ConvertHeader extends StatelessWidget {
  const ConvertHeader({
    required this.onRefresh,
    required this.isRefreshing,
    required this.onAddCurrencies,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final bool isRefreshing;
  final VoidCallback onAddCurrencies;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Currency',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: onAddCurrencies,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.add_circle_outline, color: AppTheme.muted, size: 24),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onMore,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.more_horiz, color: AppTheme.muted, size: 24),
          ),
        ],
      ),
    );
  }
}
