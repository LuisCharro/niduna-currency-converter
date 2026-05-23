import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AmountPresets extends StatelessWidget {
  const AmountPresets({
    required this.onSelected,
    required this.selectedValue,
    super.key,
  });

  final ValueChanged<String> onSelected;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final preset in _presets) ...<Widget>[
          Expanded(
            child: _PresetChip(
              label: preset.label,
              value: preset.value,
              onSelected: onSelected,
              isSelected: selectedValue == preset.value,
            ),
          ),
          if (preset != _presets.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.value,
    required this.onSelected,
    required this.isSelected,
  });

  final String label;
  final String value;
  final ValueChanged<String> onSelected;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return OutlinedButton(
      onPressed: () => onSelected(value),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        foregroundColor: isSelected ? colors.card : colors.primary,
        backgroundColor: isSelected
            ? colors.primary
            : colors.container.withValues(alpha: .45),
        side: BorderSide(
          color: isSelected
              ? colors.primary
              : colors.border.withValues(alpha: .16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    );
  }
}

const _presets = <({String label, String value})>[
  (label: '1', value: '1'),
  (label: '10', value: '10'),
  (label: '100', value: '100'),
  (label: '1K', value: '1000'),
];
