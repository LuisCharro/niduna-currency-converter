import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/designed_state_panel.dart';
import '../models/currency_quote.dart';
import 'conversion_lens_sheet.dart';
import 'currency_row_swipe_actions.dart';
import 'currency_rate_row.dart';
import '../../../shared/widgets/niduna_refresh_indicator.dart';
import '../../../shared/widgets/shimmer_loading.dart';

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
    this.isLoading = false,
    super.key,
  });

  final List<CurrencyQuote> quotes;
  final String base;
  final double amount;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onSetBase;
  final ValueChanged<String> onRemove;
  final Future<bool> Function(String code) onToggleFavorite;
  final bool maxFavoritesReached;
  final Future<void> Function()? onRefresh;
  final bool isLoading;

  @override
  State<VisibleRatesList> createState() => _VisibleRatesListState();
}

class _VisibleRatesListState extends State<VisibleRatesList> {
  String? _openCode;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    if (widget.isLoading && widget.quotes.isEmpty) {
      return ListView.separated(
        padding: AppTheme.pageInsets.copyWith(bottom: AppTheme.space2),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, __) => ShimmerLoading(child: const RateRowSkeleton()),
      );
    }

    if (widget.quotes.isEmpty) {
      return SingleChildScrollView(
        padding: AppTheme.pageInsets,
        child: DesignedStatePanel(
          icon: Icons.currency_exchange_rounded,
          title: l10n?.noRatesTitle ?? 'No rates on the ledger yet',
          subtitle:
              l10n?.noRatesSubtitle ??
              'Pull to refresh or tap sync when you are back online',
          actionLabel: l10n?.btnRefresh ?? 'Refresh',
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
              _openCode = open
                  ? quote.code
                  : _openCode == quote.code
                  ? null
                  : _openCode;
            });
          },
          onRemove: () {
            setState(() => _openCode = null);
            widget.onRemove(quote.code);
          },
          onToggleFavorite: () => _toggleFavorite(context, quote.code),
          isFavorite: quote.favorite,
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
        padding: const EdgeInsets.only(left: 62),
        child: Divider(color: colors.border.withValues(alpha: .20), height: .5),
      ),
      itemCount: widget.quotes.length,
    );

    if (widget.onRefresh != null) {
      return NidunaRefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: list,
      );
    }
    return list;
  }

  Future<void> _toggleFavorite(BuildContext context, String code) async {
    setState(() => _openCode = null);
    final added = await widget.onToggleFavorite(code);
    if (!added && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.favoritesLimitMessageUpgrade ??
                'Pin up to 3 pairs. Watch an ad or upgrade to add more.',
          ),
        ),
      );
    }
  }
}
