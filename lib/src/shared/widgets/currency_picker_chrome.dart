import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CurrencyPickerHeader extends StatelessWidget {
  const CurrencyPickerHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTheme.caption.copyWith(color: AppTheme.muted),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppTheme.muted),
        ),
      ],
    );
  }
}

class CurrencyPickerSearchField extends StatelessWidget {
  const CurrencyPickerSearchField({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Currency, country, or code',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppTheme.container,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
