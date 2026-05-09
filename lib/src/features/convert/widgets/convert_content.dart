import 'package:flutter/material.dart';

import '../domain/convert_state.dart';
import 'ad_banner_placeholder.dart';
import 'amount_card.dart';
import 'convert_header.dart';
import 'currency_rate_row.dart';
import 'no_rates_card.dart';
import 'rates_status_card.dart';

class ConvertContent extends StatelessWidget {
  const ConvertContent({
    required this.state,
    required this.onRefresh,
    super.key,
  });

  final ConvertState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: ConvertHeader(
            isRefreshing: state.isRefreshing,
            onRefresh: () => onRefresh(),
          ),
        ),
        SliverToBoxAdapter(
          child: AmountCard(lastUpdatedLabel: state.lastUpdatedLabel),
        ),
        SliverToBoxAdapter(
          child: RatesStatusCard(
            label: state.statusLabel,
            message: state.message,
            showRetry: state.status == ConvertStatus.noCache,
            onRetry: () => onRefresh(),
          ),
        ),
        if (state.hasQuotes)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverList.separated(
              itemBuilder: (context, index) =>
                  CurrencyRateRow(quote: state.quotes[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: state.quotes.length,
            ),
          )
        else
          const SliverToBoxAdapter(child: NoRatesCard()),
        const SliverToBoxAdapter(child: AdBannerPlaceholder()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
