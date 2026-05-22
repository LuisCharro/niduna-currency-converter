import 'package:flutter/material.dart';

import '../../../shared/widgets/inline_empty_panel.dart';

class ChartsEmptyState extends StatelessWidget {
  const ChartsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: InlineEmptyPanel(
        icon: Icons.show_chart_outlined,
        title: 'No chart data available',
        subtitle: 'Try another range or pair',
      ),
    );
  }
}
