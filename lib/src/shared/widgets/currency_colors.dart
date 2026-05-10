import 'package:flutter/material.dart';

class CurrencyColors {
  CurrencyColors._();

  static const Map<String, Color> _palette = <String, Color>{
    'USD': Color(0xFF2E7D32),
    'EUR': Color(0xFF0058BC),
    'GBP': Color(0xFF7B1FA2),
    'JPY': Color(0xFFC62828),
    'CHF': Color(0xFFEF6C00),
    'CAD': Color(0xFFD84315),
    'AUD': Color(0xFF00695C),
    'NZD': Color(0xFF1565C0),
    'SEK': Color(0xFF4527A0),
    'NOK': Color(0xFFAD1457),
    'DKK': Color(0xFF0277BD),
    'PLN': Color(0xFFE65100),
    'CZK': Color(0xFF283593),
    'HUF': Color(0xFFBF360C),
    'RON': Color(0xFF1B5E20),
    'BGN': Color(0xFF4A148C),
    'TRY': Color(0xFFD32F2F),
    'ILS': Color(0xFF00796B),
    'CLP': Color(0xFFC2185B),
    'PHP': Color(0xFF303F9F),
    'IDR': Color(0xFF388E3C),
    'MYR': Color(0xFFF57C00),
    'THB': Color(0xFF512DA8),
    'SGD': Color(0xFF1976D2),
    'HKD': Color(0xFFD50000),
    'KRW': Color(0xFF0D47A1),
    'MXN': Color(0xFF2E7D32),
    'ZAR': Color(0xFF00897B),
    'BRL': Color(0xFFFF6F00),
    'INR': Color(0xFFFFAB00),
    'TWD': Color(0xFF5D4037),
    'CNY': Color(0xFFE53935),
    'COP': Color(0xFF6A1B9A),
    'ARS': Color(0xFF43A047),
  };

  static Color forCode(String code) =>
      _palette[code.toUpperCase()] ?? _fallback(code);

  static Color _fallback(String code) {
    final int hash = code.codeUnits.fold<int>(0, (a, b) => a + b);
    return Color.fromRGBO(
      (hash * 137 % 200) + 55,
      (hash * 241 % 200) + 55,
      (hash * 173 % 200) + 55,
      1,
    );
  }
}
