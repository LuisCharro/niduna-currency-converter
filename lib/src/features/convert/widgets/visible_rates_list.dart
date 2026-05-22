import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/designed_state_panel.dart';
import '../models/currency_quote.dart';
import 'conversion_lens_sheet.dart';
import 'currency_row_swipe_actions.dart';
import 'currency_rate_row.dart';

class VisibleRatesList extends StatefulWidget {
  const VisibleRatesList({
    required this.quotes,
    required this.base,
    required this.amount,
    required this.onAmountChanged,
    required this.onSetBase,
    required this.onRemove,
    required this.onToggleFavorite,
    this.maxFavoritesReached = false,
    this.onRefresh,
    super.key,
  });

  final List<CurrencyQuote> quotes;
  final String base;
  final double amount;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onSetBase;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onToggleFavorite;
  final bool maxFavoritesReached;
  final Future<void> Function()? onRefresh;

  @override
  State<VisibleRatesList> createState() => _VisibleRatesListState();
}

class _VisibleRatesListState extends State<VisibleRatesList> {
  String? _openCode;

  @override
  Widget build(BuildContext context) {
    if (widget.quotes.isEmpty) {
      return SingleChildScrollView(
        padding: AppTheme.pageInsets,
        child: DesignedStatePanel(
          icon: Icons.currency_exchange_rounded,
          title: 'No rates on the ledger yet',
          subtitle: 'Pull to refresh or tap sync when you are back online',
          actionLabel: 'Refresh',
          onAction: widget.onRefresh != null ? () => widget.onRefresh!() : null,
        ),
      );
    }

    final visibleCodes = widget.quotes.map((quote) => quote.code).toSet();
    if (_openCode != null && !visibleCodes.contains(_openCode)) {
      _openCode = null;
    }

    final list = ListView.separated(
      key: const Key('convert_rates_list'),
      padding: AppTheme.pageInsets.copyWith(bottom: AppTheme.space2),
      itemBuilder: (context, index) {
        final quote = widget.quotes[index];
        return CurrencyRowSwipeActions(
          key: Key('convert_row_${quote.code}'),
          code: quote.code,
          isOpen: _openCode == quote.code,
          onOpenChanged: (open) {
            setState(() {
              _openCode = open ? quote.code : _openCode == quote.code ? null : _openCode;
            });
          },
          onRemove: () {
            setState(() => _openCode = null);
            widget.onRemove(quote.code);
          },
          onSwap: () {
            setState(() => _openCode = null);
            widget.onSetBase(quote.code);
          },
          onPressed: (position) {
            ConversionLensSheet.show(
              context: context,
              anchor: position,
              quote: quote,
              base: widget.base,
              amount: widget.amount,
              onAmountChanged: widget.onAmountChanged,
            );
          },
          child: CurrencyRateRow(quote: quote),
        );
      },
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(left: 58),
        child: Divider(
          color: AppTheme.border.withValues(alpha: .15),
          height: .5,
        ),
      ),
      itemCount: widget.quotes.length,
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: AppTheme.trendUp,
        backgroundColor: AppTheme.card,
        edgeOffset: 20,
        child: list,
      );
    }
    return list;
  }
}
