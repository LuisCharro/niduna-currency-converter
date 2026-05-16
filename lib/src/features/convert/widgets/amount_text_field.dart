import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountTextField extends StatelessWidget {
  const AmountTextField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
      ],
      onChanged: onChanged,
      decoration: const InputDecoration.collapsed(hintText: '0.00'),
      style: const TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        height: 1.05,
      ),
    );
  }
}
