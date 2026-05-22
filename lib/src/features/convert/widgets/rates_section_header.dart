import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/instrument_section_label.dart';
import '../../../shared/widgets/pill_action.dart';

class RatesSectionHeader extends StatelessWidget {
  const RatesSectionHeader({required this.onEdit, super.key});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        0,
        AppTheme.pagePadding,
        6,
      ),
      child: InstrumentSectionLabel(
        title: 'Rates',
        subtitle: 'Edit list',
        trailing: PillAction(
          label: 'Add',
          icon: Icons.add_rounded,
          onTap: onEdit,
        ),
      ),
    );
  }
}
