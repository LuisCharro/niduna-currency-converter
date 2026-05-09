import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/latest_rates_repository.dart';
import '../domain/convert_quote_builder.dart';
import '../domain/convert_state.dart';
import '../domain/latest_rates_snapshot.dart';
import '../models/currency_quote.dart';

part 'convert_controller_editing.dart';
part 'convert_controller_loading.dart';

class ConvertController extends ChangeNotifier {
  ConvertController({
    required ConvertRatesRepository repository,
    String base = 'USD',
    double amount = 100,
    List<String>? selectedCodes,
  }) : _repository = repository {
    configure(base: base, amount: amount, selectedCodes: selectedCodes);
  }

  final ConvertRatesRepository _repository;
  String _base = 'USD';
  double _amount = 100;
  String _amountText = '100.00';
  List<String> _selectedCodes = <String>['CHF', 'EUR', 'GBP', 'JPY'];
  LatestRatesSnapshot? _snapshot;

  ConvertState state = ConvertState.loading();
  bool _disposed = false;

  void configure({
    required String base,
    required double amount,
    List<String>? selectedCodes,
  }) {
    _base = base;
    _amount = amount;
    _amountText = amount.toStringAsFixed(2);
    _selectedCodes = List<String>.from(
      selectedCodes ?? <String>['CHF', 'EUR', 'GBP', 'JPY'],
    )..remove(base);
    state = ConvertState.loading().copyWith(
      base: _base,
      amountText: _amountText,
      selectedCodes: _selectedCodes,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  ConvertState _stateFromSnapshot(
    LatestRatesSnapshot snapshot,
    ConvertStatus status,
  ) {
    _snapshot = snapshot;
    return ConvertState(
      status: status,
      quotes: buildQuotes(
        snapshot: snapshot,
        amount: _amount,
        quoteCodes: _selectedCodes,
      ),
      lastUpdatedLabel: _formatUpdated(snapshot),
      base: _base,
      amountText: _amountText,
      selectedCodes: List<String>.unmodifiable(_selectedCodes),
    );
  }

  String _formatUpdated(LatestRatesSnapshot snapshot) {
    final date = snapshot.date ?? snapshot.savedAt;
    return 'Updated: ${DateFormat('MMM d, HH:mm').format(date)}';
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
