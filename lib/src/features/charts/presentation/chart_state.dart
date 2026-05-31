import '../../../core/currency/supported_currencies.dart';
import '../domain/chart_range.dart';

enum ChartStatus { initial, loading, loaded, error }

class ChartState {
  const ChartState({
    this.status = ChartStatus.initial,
    this.base = 'USD',
    this.quote = 'EUR',
    this.range = ChartRange.oneMonth,
    this.data = const {},
    this.lastUpdated,
    this.message,
  });

  final ChartStatus status;
  final String base;
  final String quote;
  final ChartRange range;
  final Map<DateTime, double> data;
  final DateTime? lastUpdated;
  final String? message;

  double? get high {
    if (data.isEmpty) return null;
    return data.values.reduce((a, b) => a > b ? a : b);
  }

  double? get low {
    if (data.isEmpty) return null;
    return data.values.reduce((a, b) => a < b ? a : b);
  }

  double? get changePercent {
    final sorted = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (sorted.length < 2) return null;
    final first = sorted.first.value;
    final last = sorted.last.value;
    if (first == 0) return null;
    return ((last - first) / first) * 100;
  }

  double? get currentRate {
    if (data.isEmpty) return null;
    final sorted = data.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return sorted.first.value;
  }

  String get pairLabel => '$base → $quote';

  bool get includesCrypto => isCryptoCurrency(base) || isCryptoCurrency(quote);
}

extension ChartStateCopyWith on ChartState {
  ChartState copyWith({
    ChartStatus? status,
    String? base,
    String? quote,
    ChartRange? range,
    Map<DateTime, double>? data,
    DateTime? lastUpdated,
    String? message,
  }) {
    return ChartState(
      status: status ?? this.status,
      base: base ?? this.base,
      quote: quote ?? this.quote,
      range: range ?? this.range,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      message: message,
    );
  }
}
