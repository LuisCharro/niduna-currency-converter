import '../models/currency_quote.dart';

enum ConvertStatus { loading, refreshing, fresh, cached, stale, noCache }

class ConvertState {
  const ConvertState({
    required this.status,
    required this.quotes,
    required this.lastUpdatedLabel,
    required this.nextUpdateLabel,
    required this.base,
    required this.amountText,
    required this.selectedCodes,
    this.message,
  });

  factory ConvertState.loading() => const ConvertState(
    status: ConvertStatus.loading,
    quotes: <CurrencyQuote>[],
    lastUpdatedLabel: 'Loading rates',
    nextUpdateLabel: 'Updates once daily',
    base: 'USD',
    amountText: '100.00',
    selectedCodes: <String>['EUR', 'GBP', 'JPY'],
  );

  final ConvertStatus status;
  final List<CurrencyQuote> quotes;
  final String lastUpdatedLabel;
  final String nextUpdateLabel;
  final String base;
  final String amountText;
  final List<String> selectedCodes;
  final String? message;

  bool get hasQuotes => quotes.isNotEmpty;
  bool get isRefreshing => status == ConvertStatus.refreshing;

  ConvertState copyWith({
    ConvertStatus? status,
    List<CurrencyQuote>? quotes,
    String? lastUpdatedLabel,
    String? nextUpdateLabel,
    String? base,
    String? amountText,
    List<String>? selectedCodes,
    String? message,
  }) {
    return ConvertState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      lastUpdatedLabel: lastUpdatedLabel ?? this.lastUpdatedLabel,
      nextUpdateLabel: nextUpdateLabel ?? this.nextUpdateLabel,
      base: base ?? this.base,
      amountText: amountText ?? this.amountText,
      selectedCodes: selectedCodes ?? this.selectedCodes,
      message: message,
    );
  }

  String get statusLabel {
    return switch (status) {
      ConvertStatus.loading => 'Loading latest rates',
      ConvertStatus.refreshing => 'Refreshing rates',
      ConvertStatus.fresh => 'Fresh rates',
      ConvertStatus.cached => 'Cached rates',
      ConvertStatus.stale => 'Offline: cached rates',
      ConvertStatus.noCache => 'No rates available',
    };
  }
}
