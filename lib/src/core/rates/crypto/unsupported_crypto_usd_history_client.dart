import 'crypto_usd_history_client.dart';
import 'crypto_usd_history_snapshot.dart';

class UnsupportedCryptoUsdHistoryClient implements CryptoUsdHistoryClient {
  const UnsupportedCryptoUsdHistoryClient(this.message);

  final String message;

  @override
  Future<CryptoUsdHistorySnapshot> fetchUsdHistory({
    required String code,
    required DateTime from,
    required DateTime to,
  }) {
    throw CryptoUsdHistoryException(message);
  }
}
