import '../models/currency_quote.dart';

enum ConvertStatus { loading, refreshing, fresh, cached, stale, noCache }

class ConvertState {
  const ConvertState({
    required this.status,
    required this.quotes,
    required this.lastUpdatedLabel,
    this.message,
  });

  factory ConvertState.loading() => const ConvertState(
    status: ConvertStatus.loading,
    quotes: <CurrencyQuote>[],
    lastUpdatedLabel: 'Loading rates',
  );

  final ConvertStatus status;
  final List<CurrencyQuote> quotes;
  final String lastUpdatedLabel;
  final String? message;

  bool get hasQuotes => quotes.isNotEmpty;
  bool get isRefreshing => status == ConvertStatus.refreshing;

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
