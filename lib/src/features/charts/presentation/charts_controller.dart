import 'package:flutter/foundation.dart';

import '../../../core/rates/rates_service.dart';
import '../../../core/rates/models/rates_result.dart';
import '../domain/chart_range.dart';

enum ChartStatus {
  initial,
  loading,
  loaded,
  error,
}

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
}

class ChartsController extends ChangeNotifier {
  ChartsController({
    required RatesService ratesService,
    String base = 'USD',
    String quote = 'EUR',
    ChartRange range = ChartRange.oneMonth,
  })  : _ratesService = ratesService,
       _state = ChartState(base: base, quote: quote, range: range);

  final RatesService _ratesService;
  ChartState _state;
  bool _disposed = false;

  ChartState get state => _state;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _setState(ChartState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  void setPair(String base, String quote) {
    if (base == _state.base && quote == _state.quote) return;
    _setState(_state.copyWith(
      base: base,
      quote: quote,
      status: ChartStatus.loading,
      data: const {},
    ));
    _load();
  }

  void setRange(ChartRange range) {
    if (range == _state.range) return;
    _setState(_state.copyWith(
      range: range,
      status: ChartStatus.loading,
      data: const {},
    ));
    _load();
  }

  void load() {
    if (_state.status == ChartStatus.loading) return;
    _setState(_state.copyWith(status: ChartStatus.loading));
    _load();
  }

  Future<void> _load() async {
    final from = _state.range.fromDate();
    final to = DateTime.now();

    final result = await _ratesService.getHistoricalRates(
      base: _state.base,
      quote: _state.quote,
      rangeKey: _state.range.cacheKey,
      from: from,
      to: to,
    );

    final newData = result.snapshot?.data ?? <DateTime, double>{};
    final newStatus = result.status == HistoricalStatus.error
        ? ChartStatus.error
        : ChartStatus.loaded;
    final newMessage = result.message;

    _setState(_state.copyWith(
      data: newData,
      lastUpdated: newData.isNotEmpty ? DateTime.now() : null,
      status: newStatus,
      message: newMessage,
    ));
  }
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