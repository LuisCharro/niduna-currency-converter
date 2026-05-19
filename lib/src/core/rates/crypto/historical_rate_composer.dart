import '../models/rates_snapshot.dart';
import 'crypto_usd_history_snapshot.dart';

class HistoricalRateComposer {
  const HistoricalRateComposer();

  HistoricalSnapshot composeCryptoToCrypto({
    required String base,
    required String quote,
    required CryptoUsdHistorySnapshot baseUsd,
    required CryptoUsdHistorySnapshot quoteUsd,
    required DateTime from,
    required DateTime to,
  }) {
    final data = <DateTime, double>{};
    for (final day in _daysBetween(from, to)) {
      final baseValue = baseUsd.pricesUsd[day];
      final quoteValue = quoteUsd.pricesUsd[day];
      if (baseValue == null || quoteValue == null || quoteValue <= 0) continue;
      data[day] = baseValue / quoteValue;
    }
    return _snapshot(base: base, quote: quote, from: from, to: to, data: data);
  }

  HistoricalSnapshot composeFiatToCrypto({
    required String base,
    required String quote,
    required HistoricalSnapshot fiatToUsd,
    required CryptoUsdHistorySnapshot quoteUsd,
    required DateTime from,
    required DateTime to,
  }) {
    final data = <DateTime, double>{};
    for (final day in _daysBetween(from, to)) {
      final fiatValue = _carryForward(fiatToUsd.data, day);
      final cryptoValue = quoteUsd.pricesUsd[day];
      if (fiatValue == null || cryptoValue == null || cryptoValue <= 0) {
        continue;
      }
      data[day] = fiatValue / cryptoValue;
    }
    return _snapshot(base: base, quote: quote, from: from, to: to, data: data);
  }

  HistoricalSnapshot composeCryptoToFiat({
    required String base,
    required String quote,
    required CryptoUsdHistorySnapshot baseUsd,
    required HistoricalSnapshot usdToFiat,
    required DateTime from,
    required DateTime to,
  }) {
    final data = <DateTime, double>{};
    for (final day in _daysBetween(from, to)) {
      final cryptoValue = baseUsd.pricesUsd[day];
      final fiatValue = _carryForward(usdToFiat.data, day);
      if (cryptoValue == null || fiatValue == null) {
        continue;
      }
      data[day] = cryptoValue * fiatValue;
    }
    return _snapshot(base: base, quote: quote, from: from, to: to, data: data);
  }

  HistoricalSnapshot _snapshot({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
    required Map<DateTime, double> data,
  }) {
    return HistoricalSnapshot(
      base: base,
      quote: quote,
      coveredFrom: from,
      coveredTo: to,
      data: data,
      savedAt: DateTime.now(),
    );
  }

  double? _carryForward(Map<DateTime, double> data, DateTime day) {
    final dates = data.keys.toList()..sort();
    double? current;
    for (final date in dates) {
      if (date.isAfter(day)) break;
      current = data[date];
    }
    return current;
  }

  Iterable<DateTime> _daysBetween(DateTime from, DateTime to) sync* {
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!cursor.isAfter(end)) {
      yield cursor;
      cursor = cursor.add(const Duration(days: 1));
    }
  }
}
