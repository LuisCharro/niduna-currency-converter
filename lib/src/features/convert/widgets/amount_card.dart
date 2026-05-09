import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_panel.dart';

class AmountCard extends StatelessWidget {
  const AmountCard({required this.lastUpdatedLabel, super.key});

  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        AmountPanel(lastUpdatedLabel: lastUpdatedLabel),
        Positioned(
          bottom: 0,
          child: FloatingActionButton.small(
            heroTag: 'swap-currencies',
            elevation: 2,
            backgroundColor: AppTheme.card,
            foregroundColor: AppTheme.primary,
            onPressed: () {},
            child: const Icon(Icons.swap_vert),
          ),
        ),
      ],
    );
  }
}
