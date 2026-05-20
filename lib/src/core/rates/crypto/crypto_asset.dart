class CryptoAsset {
  const CryptoAsset({
    required this.code,
    required this.coinPaprikaId,
    required this.coinCapId,
  });

  final String code;
  final String coinPaprikaId;
  final String coinCapId;
}

const List<CryptoAsset> supportedCryptoAssets = <CryptoAsset>[
  CryptoAsset(code: 'BTC', coinPaprikaId: 'btc-bitcoin', coinCapId: 'bitcoin'),
  CryptoAsset(code: 'ETH', coinPaprikaId: 'eth-ethereum', coinCapId: 'ethereum'),
];

CryptoAsset cryptoAssetByCode(String code) {
  return supportedCryptoAssets.firstWhere(
    (asset) => asset.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unsupported crypto'),
  );
}
