class CryptoAsset {
  const CryptoAsset({required this.code, required this.coinPaprikaId});

  final String code;
  final String coinPaprikaId;
}

const List<CryptoAsset> supportedCryptoAssets = <CryptoAsset>[
  CryptoAsset(code: 'BTC', coinPaprikaId: 'btc-bitcoin'),
  CryptoAsset(code: 'ETH', coinPaprikaId: 'eth-ethereum'),
];

CryptoAsset cryptoAssetByCode(String code) {
  return supportedCryptoAssets.firstWhere(
    (asset) => asset.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unsupported crypto'),
  );
}
