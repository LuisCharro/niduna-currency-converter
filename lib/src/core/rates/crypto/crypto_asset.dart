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
  CryptoAsset(code: 'SOL', coinPaprikaId: 'sol-solana', coinCapId: 'solana'),
  CryptoAsset(code: 'XRP', coinPaprikaId: 'xrp-xrp', coinCapId: 'ripple'),
  CryptoAsset(code: 'ADA', coinPaprikaId: 'ada-cardano', coinCapId: 'cardano'),
  CryptoAsset(code: 'DOGE', coinPaprikaId: 'doge-dogecoin', coinCapId: 'dogecoin'),
  CryptoAsset(code: 'AVAX', coinPaprikaId: 'avax-avalanche', coinCapId: 'avalanche-2'),
  CryptoAsset(code: 'USDT', coinPaprikaId: 'usdt-tether', coinCapId: 'tether'),
  CryptoAsset(code: 'USDC', coinPaprikaId: 'usdc-usd-coin', coinCapId: 'usd-coin'),
  CryptoAsset(code: 'BNB', coinPaprikaId: 'bnb-binance-coin', coinCapId: 'binancecoin'),
  CryptoAsset(code: 'MATIC', coinPaprikaId: 'matic-polygon', coinCapId: 'matic-network'),
];

CryptoAsset cryptoAssetByCode(String code) {
  return supportedCryptoAssets.firstWhere(
    (asset) => asset.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unsupported crypto'),
  );
}
