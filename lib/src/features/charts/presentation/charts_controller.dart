import 'package:flutter/foundation.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/rates/rates_service.dart';
import '../../../core/rates/models/rates_result.dart';
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

class ChartsController extends ChangeNotifier {
  ChartsController({
    required RatesService ratesService,
    String defaultBase = 'USD',
    String defaultQuote = 'EUR',
    ChartRange range = ChartRange.oneMonth,
  }) : _ratesService = ratesService,
       _state = ChartState(
         base: defaultBase,
         quote: defaultQuote,
         range: range,
       );

  final RatesService _ratesService;
  ChartState _state;
  bool _disposed = false;
  int _requestVersion = 0;

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
    final range = _normalizeRangeForPair(
      base: base,
      quote: quote,
      range: _state.range,
    );
    _setState(
      _state.copyWith(
        base: base,
        quote: quote,
        range: range,
        status: ChartStatus.loading,
        data: const {},
      ),
    );
    _load();
  }

  void setRange(ChartRange range) {
    final nextRange = _normalizeRangeForPair(
      base: _state.base,
      quote: _state.quote,
      range: range,
    );
    if (nextRange == _state.range || nextRange.locked) return;
    _setState(
      _state.copyWith(
        range: nextRange,
        status: ChartStatus.loading,
        data: const {},
      ),
    );
    _load();
  }

  void swapPair() {
    final nextBase = _state.quote;
    final nextQuote = _state.base;
    setPair(nextBase, nextQuote);
  }

  void load() {
    if (_state.status == ChartStatus.loading) return;
    _setState(_state.copyWith(status: ChartStatus.loading));
    _load();
  }

  Future<void> _load() async {
    final requestVersion = ++_requestVersion;
    final from = _state.range.fromDate();
    if (from == null) {
      _setState(
        _state.copyWith(
          status: ChartStatus.error,
          message: 'Selected range is not available yet.',
        ),
      );
      return;
    }
    final to = DateTime.now();

    final result = await _ratesService.getHistoricalRates(
      base: _state.base,
      quote: _state.quote,
      from: from,
      to: to,
    );

    if (_disposed || requestVersion != _requestVersion) {
      return;
    }

    final newData = result.snapshot?.data ?? <DateTime, double>{};
    final newStatus = result.status == HistoricalStatus.error
        ? ChartStatus.error
        : ChartStatus.loaded;
    final newMessage = result.message;

    _setState(
      _state.copyWith(
        data: newData,
        lastUpdated: newData.isNotEmpty ? DateTime.now() : null,
        status: newStatus,
        message: newMessage,
      ),
    );
  }

  ChartRange _normalizeRangeForPair({
    required String base,
    required String quote,
    required ChartRange range,
  }) {
    final includesCrypto = isCryptoCurrency(base) || isCryptoCurrency(quote);
    if (!includesCrypto || range.supportsCrypto) {
      return range;
    }
    return ChartRange.oneYear;
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
