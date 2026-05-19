import '../domain/latest_rates_snapshot.dart';
import 'latest_rates_client.dart';
import 'latest_rates_cache.dart';

abstract class ConvertRatesRepository {
  Future<LatestRatesSnapshot?> readCached(String base);
  Future<LatestRatesSnapshot> fetchLatest(String base);
}

class LatestRatesRepository implements ConvertRatesRepository {
  const LatestRatesRepository({
    required LatestRatesClient client,
    required LatestRatesCache cache,
  }) : _client = client,
       _cache = cache;

  final LatestRatesClient _client;
  final LatestRatesCache _cache;

  @override
  Future<LatestRatesSnapshot?> readCached(String base) => _cache.read(base);

  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async {
    final snapshot = await _client.fetchLatest(base);
    await _cache.write(snapshot);
    return snapshot;
  }
}
