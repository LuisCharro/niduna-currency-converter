import 'rates_snapshot.dart';

enum RatesStatus { fresh, cached, stale, noCache, error }

class RatesResult {
  const RatesResult({required this.status, this.snapshot, this.message});

  final RatesStatus status;
  final RatesSnapshot? snapshot;
  final String? message;

  bool get hasData => snapshot != null && snapshot!.rates.isNotEmpty;
}

enum HistoricalStatus { fresh, cached, noCache, error }

class HistoricalResult {
  const HistoricalResult({required this.status, this.snapshot, this.message});

  final HistoricalStatus status;
  final HistoricalSnapshot? snapshot;
  final String? message;

  bool get hasData => snapshot != null && !snapshot!.isEmpty;
}
