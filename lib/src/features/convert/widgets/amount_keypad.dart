import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
    this.onOperator,
    this.onEquals,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;
  final void Function(String)? onOperator;
  final VoidCallback? onEquals;

  bool get _hasOperators => onOperator != null && onEquals != null;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (_hasOperators) {
      children.add(
        SizedBox(
          height: 48,
          child: Row(
            children: <Widget>[
              _OpKey(label: '+', onTap: () => onOperator!('+')),
              _OpKey(label: '−', onTap: () => onOperator!('-')),
              _OpKey(label: '×', onTap: () => onOperator!('*')),
              _OpKey(label: '÷', onTap: () => onOperator!('/')),
              const Spacer(),
              _OpKey(icon: Icons.drag_handle, onTap: onEquals!, bgColor: true),
            ],
          ),
        ),
      );
      children.add(const SizedBox(height: 10));
    }

    children.add(
      LayoutBuilder(
        builder: (context, constraints) {
          final keyWidth = (constraints.maxWidth - 20) / 3;
          final aspectRatio = keyWidth / 54;
          return GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: aspectRatio,
            children: <Widget>[
              for (final digit in <String>[
                '1',
                '2',
                '3',
                '4',
                '5',
                '6',
                '7',
                '8',
                '9',
              ])
                _Key(label: digit, onTap: () => onDigit(digit)),
              _Key(label: '.', onTap: onDecimal),
              _Key(label: '0', onTap: () => onDigit('0')),
              _Key(icon: Icons.backspace_outlined, onTap: onBackspace),
            ],
          );
        },
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.container.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(18),
      shadowColor: colors.primary.withValues(alpha: .08),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        overlayColor: WidgetStatePropertyAll(
          colors.primary.withValues(alpha: .06),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border.withValues(alpha: .08)),
          ),
          child: Center(
            child: icon == null
                ? Text(
                    label!,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: colors.text,
                    ),
                  )
                : Icon(icon, color: colors.text, size: 22),
          ),
        ),
      ),
    );
  }
}

class _OpKey extends StatelessWidget {
  const _OpKey({
    this.label,
    this.icon,
    required this.onTap,
    this.bgColor = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool bgColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Expanded(
      child: Material(
        color: bgColor
            ? colors.primary.withValues(alpha: .1)
            : colors.container.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          overlayColor: WidgetStatePropertyAll(
            colors.primary.withValues(alpha: .06),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border.withValues(alpha: .08)),
            ),
            child: Center(
              child: label != null
                  ? Text(
                      label!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 20,
                      color: colors.text.withValues(alpha: .6),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
