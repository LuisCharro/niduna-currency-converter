import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ConvertHeader extends StatelessWidget {
  const ConvertHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: <Widget>[
          const Icon(Icons.security, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Niduna Convert',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  'LOCAL-ONLY DATA',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.sync, color: AppTheme.primary, size: 20),
          ),
        ],
      ),
    );
  }
}
