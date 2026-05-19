import 'crypto_usd_history_snapshot.dart';

abstract class CryptoUsdHistoryClient {
  Future<CryptoUsdHistorySnapshot> fetchUsdHistory({
    required String code,
    required DateTime from,
    required DateTime to,
  });
}

class CryptoUsdHistoryException implements Exception {
  const CryptoUsdHistoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
