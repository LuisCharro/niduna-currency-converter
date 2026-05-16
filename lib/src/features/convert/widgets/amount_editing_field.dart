import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'amount_text_field.dart';

class AmountEditingField extends StatefulWidget {
  const AmountEditingField({
    required this.amountText,
    required this.onAmountChanged,
    super.key,
  });

  final String amountText;
  final ValueChanged<String> onAmountChanged;

  @override
  State<AmountEditingField> createState() => _AmountEditingFieldState();
}

class _AmountEditingFieldState extends State<AmountEditingField> {
  late final FocusNode _focusNode = FocusNode()..addListener(_handleFocus);
  late final TextEditingController _controller = TextEditingController(
    text: widget.amountText,
  );
  bool _isFocused = false;

  @override
  void didUpdateWidget(covariant AmountEditingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amountText == oldWidget.amountText ||
        widget.amountText == _controller.text) {
      return;
    }
    _controller.value = TextEditingValue(
      text: widget.amountText,
      selection: TextSelection.collapsed(offset: widget.amountText.length),
    );
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus && _controller.text.isNotEmpty) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  void _setAmount(String value) {
    widget.onAmountChanged(value);
    setState(() {});
  }

  void _clearAmount() {
    _controller.clear();
    _setAmount('');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
      decoration: BoxDecoration(
        color: _isFocused
            ? AppTheme.containerHigh.withValues(alpha: .42)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: AmountTextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _setAmount,
            ),
          ),
          if (_isFocused && _controller.text.isNotEmpty)
            IconButton(
              onPressed: _clearAmount,
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: 'Clear amount',
              color: AppTheme.muted,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
        ],
      ),
    );
  }
}
