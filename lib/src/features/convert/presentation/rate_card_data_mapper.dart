import '../domain/convert_state.dart';
import '../models/rate_card_data.dart';

/// Builds the rate-card payload from the current Convert state. Pure.
RateCardData rateCardDataFromState(ConvertState state) {
  final amount = double.tryParse(state.amountText);
  final amountLabel = amount == null
      ? state.amountText
      : (amount == amount.roundToDouble()
          ? amount.round().toString()
          : amount.toStringAsFixed(2));

  return RateCardData(
    baseAmountLabel: '$amountLabel ${state.base}',
    rows: state.quotes
        .map((q) => RateCardRowData(
              name: q.name,
              valueLabel: '${q.symbol} ${q.amount}',
            ))
        .toList(),
    footerLabel: state.lastUpdatedLabel,
  );
}
