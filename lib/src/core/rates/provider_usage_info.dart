import 'provider_config.dart';

class ProviderUsageRole {
  const ProviderUsageRole({
    required this.title,
    required this.provider,
    required this.details,
  });

  final String title;
  final String provider;
  final List<String> details;
}

class ProviderMatrixRow {
  const ProviderMatrixRow({
    required this.provider,
    required this.role,
    required this.status,
  });

  final String provider;
  final String role;
  final String status;
}

class ProviderUsageInfo {
  const ProviderUsageInfo({
    required this.profileLabel,
    required this.profileValue,
    required this.devModeValue,
    required this.cryptoChartsEnabled,
    required this.roles,
    required this.matrix,
    required this.cacheLines,
  });

  final String profileLabel;
  final String profileValue;
  final String devModeValue;
  final bool cryptoChartsEnabled;
  final List<ProviderUsageRole> roles;
  final List<ProviderMatrixRow> matrix;
  final List<String> cacheLines;

  bool get isReleaseSafe => ProviderConfig.isPlayStoreSafe;

  static ProviderUsageInfo fromBuildConfig() {
    final profileValue = switch (ProviderConfig.profile) {
      ProviderProfile.releaseSafe => 'release_safe',
      ProviderProfile.devCoinPaprika => 'dev_coinpaprika',
    };

    final latestStatus = ProviderConfig.isPlayStoreSafe
        ? 'Primary'
        : 'Primary + fallback';

    final matrix = <ProviderMatrixRow>[
      const ProviderMatrixRow(
        provider: 'Frankfurter / ECB',
        role: 'Fiat latest + fiat history',
        status: 'Primary',
      ),
      ProviderMatrixRow(
        provider: 'fawazahmed0/exchange-api',
        role: 'Crypto latest + history',
        status: latestStatus,
      ),
      ProviderMatrixRow(
        provider: 'CoinPaprika',
        role: 'Crypto latest + history',
        status: ProviderConfig.isPlayStoreSafe ? 'Not used' : 'Primary',
      ),
    ];

    final roles = <ProviderUsageRole>[
      const ProviderUsageRole(
        title: 'Fiat latest',
        provider: 'Frankfurter / ECB',
        details: <String>[
          'Refreshes on the daily app policy.',
          'Stored in latest fiat cache.',
        ],
      ),
      const ProviderUsageRole(
        title: 'Fiat charts',
        provider: 'Frankfurter / ECB',
        details: <String>[
          'Daily points up to 2 years.',
          'Stored in historical chart cache.',
        ],
      ),
      ProviderUsageRole(
        title: 'Crypto latest',
        provider: ProviderConfig.latestProvidersLabel,
        details: const <String>[
          'BTC/ETH use build-profile chain.',
          'Stored in crypto latest cache.',
        ],
      ),
      ProviderUsageRole(
        title: 'Crypto charts',
        provider: ProviderConfig.chartsProviderLabel,
        details: <String>[
          ProviderConfig.cryptoChartsEnabled
              ? 'Daily points up to 1 year.'
              : 'Disabled in this build profile.',
          'Stored in crypto history cache.',
        ],
      ),
    ];

    return ProviderUsageInfo(
      profileLabel: ProviderConfig.profileLabel,
      profileValue: profileValue,
      devModeValue: 'APP_DEV_MODE=${ProviderConfig.isPlayStoreSafe ? 'false' : 'true'}',
      cryptoChartsEnabled: ProviderConfig.cryptoChartsEnabled,
      roles: roles,
      matrix: matrix,
      cacheLines: const <String>[
        'Clear all data removes fiat latest, crypto latest, fiat charts, crypto charts, and temporary chart unlocks.',
        'Theme and normal app preferences are not removed.',
      ],
    );
  }
}
