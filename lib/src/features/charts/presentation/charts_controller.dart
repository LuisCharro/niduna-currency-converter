import 'package:flutter/foundation.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/rates/models/rates_result.dart';
import '../domain/chart_range.dart';
import '../domain/chart_repository.dart';
import 'chart_state.dart';

class ChartsController extends ChangeNotifier {
  ChartsController({
    required ChartRepository repository,
    required bool allowCryptoCharts,
    String defaultBase = 'USD',
    String defaultQuote = 'EUR',
    ChartRange range = ChartRange.oneMonth,
  }) : _repository = repository,
       _allowCryptoCharts = allowCryptoCharts,
       _state = ChartState(
         base: _normalizeCode(defaultBase, allowCryptoCharts),
         quote: _normalizeCode(
           defaultQuote,
           allowCryptoCharts,
           fallback: 'EUR',
         ),
         range: range,
       );

  final ChartRepository _repository;
  final bool _allowCryptoCharts;
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

  Future<void> refresh() async {
    if (_state.status == ChartStatus.loading) return;
    _setState(_state.copyWith(status: ChartStatus.loading));
    await _load();
  }

  Future<void> _load() async {
    final requestVersion = ++_requestVersion;
    if (_state.includesCrypto && !_allowCryptoCharts) {
      _setState(
        _state.copyWith(
          status: ChartStatus.error,
          message: 'Crypto charts are not available in this release.',
        ),
      );
      return;
    }
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

    final result = await _repository.getHistoricalRates(
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

  static String _normalizeCode(
    String code,
    bool allowCryptoCharts, {
    String fallback = 'USD',
  }) {
    if (!allowCryptoCharts && isCryptoCurrency(code)) {
      return fallback;
    }
    return code;
  }
}
