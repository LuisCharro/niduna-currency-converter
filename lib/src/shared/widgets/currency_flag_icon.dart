import 'package:flutter/material.dart';

class CurrencyFlagIcon extends StatelessWidget {
  const CurrencyFlagIcon({
    required this.code,
    required this.symbol,
    this.radius = 20,
    super.key,
  });

  final String code;
  final String symbol;
  final double radius;

  static const Map<String, String> _assetMap = <String, String>{
    'USD': 'assets/icons/currencies/usd.png',
    'EUR': 'assets/icons/currencies/eur.png',
    'GBP': 'assets/icons/currencies/gbp.png',
    'JPY': 'assets/icons/currencies/jpy.png',
    'CHF': 'assets/icons/currencies/chf.png',
    'CAD': 'assets/icons/currencies/cad.png',
    'AUD': 'assets/icons/currencies/aud.png',
    'NZD': 'assets/icons/currencies/nzd.png',
    'SEK': 'assets/icons/currencies/sek.png',
    'NOK': 'assets/icons/currencies/nok.png',
    'DKK': 'assets/icons/currencies/dkk.png',
    'PLN': 'assets/icons/currencies/pln.png',
    'CZK': 'assets/icons/currencies/czk.png',
    'HUF': 'assets/icons/currencies/huf.png',
    'RON': 'assets/icons/currencies/ron.png',
    'BGN': 'assets/icons/currencies/bgn.png',
    'TRY': 'assets/icons/currencies/try.png',
    'ILS': 'assets/icons/currencies/ils.png',
    'CLP': 'assets/icons/currencies/clp.png',
    'PHP': 'assets/icons/currencies/php.png',
    'IDR': 'assets/icons/currencies/idr.png',
    'MYR': 'assets/icons/currencies/myr.png',
    'THB': 'assets/icons/currencies/thb.png',
    'SGD': 'assets/icons/currencies/sgd.png',
    'HKD': 'assets/icons/currencies/hkd.png',
    'KRW': 'assets/icons/currencies/krw.png',
    'MXN': 'assets/icons/currencies/mxn.png',
    'ZAR': 'assets/icons/currencies/zar.png',
    'BRL': 'assets/icons/currencies/brl.png',
    'INR': 'assets/icons/currencies/inr.png',
    'TWD': 'assets/icons/currencies/twd.png',
    'CNY': 'assets/icons/currencies/cny.png',
    'BTC': 'assets/icons/currencies/btc.png',
    'ETH': 'assets/icons/currencies/eth.png',
    'COP': 'assets/icons/currencies/cop.png',
    'ARS': 'assets/icons/currencies/ars.png',
  };

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetMap[code.toUpperCase()];
    if (assetPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(assetPath),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Text(
        symbol,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.75),
      ),
    );
  }
}
