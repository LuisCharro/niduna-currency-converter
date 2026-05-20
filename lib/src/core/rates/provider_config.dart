import 'package:flutter/foundation.dart';

enum ProviderProfile { releaseSafe, devCoinPaprika }

enum CryptoLatestProvider { coinPaprika, fawazahmed0 }

enum CryptoHistoryProvider { none, coinPaprika, coingecko }

class ProviderInfo {
  const ProviderInfo({
    required this.name,
    required this.type,
    required this.active,
  });
  final String name;
  final String type;
  final bool active;
}

class ProviderConfig {
  static const String _profileValue = String.fromEnvironment(
    'PROVIDER_PROFILE',
    defaultValue: 'release_safe',
  );

  static ProviderProfile get profile {
    switch (_profileValue) {
      case 'dev_coinpaprika':
        return ProviderProfile.devCoinPaprika;
      case 'release_safe':
      default:
        return ProviderProfile.releaseSafe;
    }
  }

  static bool get isPlayStoreSafe => profile == ProviderProfile.releaseSafe;

  static bool get cryptoChartsEnabled =>
      cryptoHistoryProvider != CryptoHistoryProvider.none;

  static List<CryptoLatestProvider> get cryptoLatestOrder {
    switch (profile) {
      case ProviderProfile.devCoinPaprika:
        return const <CryptoLatestProvider>[
          CryptoLatestProvider.coinPaprika,
          CryptoLatestProvider.fawazahmed0,
        ];
      case ProviderProfile.releaseSafe:
        return const <CryptoLatestProvider>[CryptoLatestProvider.fawazahmed0];
    }
  }

  static CryptoHistoryProvider get cryptoHistoryProvider {
    switch (profile) {
      case ProviderProfile.devCoinPaprika:
        return CryptoHistoryProvider.coinPaprika;
      case ProviderProfile.releaseSafe:
        return CryptoHistoryProvider.coingecko;
    }
  }

  static String get profileLabel {
    switch (profile) {
      case ProviderProfile.devCoinPaprika:
        return 'Developer CoinPaprika';
      case ProviderProfile.releaseSafe:
        return 'Release safe';
    }
  }

  static String get latestProvidersLabel {
    return cryptoLatestOrder.map(_latestProviderLabel).join(' -> ');
  }

  static String get chartsProviderLabel {
    switch (cryptoHistoryProvider) {
      case CryptoHistoryProvider.coinPaprika:
        return 'CoinPaprika historical ticks';
      case CryptoHistoryProvider.coingecko:
        return 'CoinGecko historical data';
      case CryptoHistoryProvider.none:
        return 'Disabled in this build';
    }
  }

  static List<ProviderInfo> get allProviders => <ProviderInfo>[
        ProviderInfo(
          name: 'Frankfurter',
          type: 'Fiat latest + history',
          active: true,
        ),
        ProviderInfo(
          name: 'fawazahmed0',
          type: 'Crypto latest',
          active: isPlayStoreSafe,
        ),
        ProviderInfo(
          name: 'CoinPaprika',
          type: 'Crypto latest + history',
          active: !isPlayStoreSafe,
        ),
        ProviderInfo(
          name: 'CoinGecko',
          type: 'Crypto history',
          active: cryptoHistoryProvider == CryptoHistoryProvider.coingecko,
        ),
      ];

  static void validateReleaseMode() {
    if (kReleaseMode && !isPlayStoreSafe) {
      throw StateError(
        'Release builds must use a Play Store safe provider profile.',
      );
    }
  }

  static String _latestProviderLabel(CryptoLatestProvider provider) {
    switch (provider) {
      case CryptoLatestProvider.coinPaprika:
        return 'CoinPaprika';
      case CryptoLatestProvider.fawazahmed0:
        return 'fawazahmed0/exchange-api';
    }
  }
}