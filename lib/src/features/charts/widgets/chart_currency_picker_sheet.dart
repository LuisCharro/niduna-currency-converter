import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/monetization/models/temporary_unlock.dart';
import '../../../core/monetization/monetization_controller.dart';
import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_picker_chrome.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../../convert/widgets/ad_banner_placeholder.dart';
import '../../settings/widgets/iap_purchase_player.dart';
import 'locked_pair_action_sheet.dart';
import 'rewarded_ad_player.dart';

class ChartCurrencyPickerSheet extends StatefulWidget {
  const ChartCurrencyPickerSheet({
    required this.title,
    required this.selectedCode,
    required this.controller,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.selectingBase,
    super.key,
  });

  final String title;
  final String selectedCode;
  final MonetizationController controller;
  final String baseCurrency;
  final String quoteCurrency;
  final bool selectingBase;

  @override
  State<ChartCurrencyPickerSheet> createState() =>
      _ChartCurrencyPickerSheetState();
}

class _ChartCurrencyPickerSheetState extends State<ChartCurrencyPickerSheet> {
  String _query = '';

  /// The other side of the pair — what stays fixed while user picks.
  String get _fixedSide =>
      widget.selectingBase ? widget.quoteCurrency : widget.baseCurrency;

  bool _isUnlocked(String code) {
    if (code == _fixedSide) return true; // the fixed side is always valid
    final candidateBase = widget.selectingBase ? code : widget.baseCurrency;
    final candidateQuote = widget.selectingBase ? widget.quoteCurrency : code;
    return widget.controller.isChartPairUnlocked(candidateBase, candidateQuote);
  }

  bool _isTempUnlocked(String code) {
    if (code == _fixedSide) return false; // fixed side never shows temp badge
    if (_isFreeDefaultCurrency(code)) return false;
    final candidateBase = widget.selectingBase ? code : widget.baseCurrency;
    final candidateQuote = widget.selectingBase ? widget.quoteCurrency : code;
    final canonical = TemporaryUnlock.canonicalKey(
      candidateBase,
      candidateQuote,
    );
    // Free-default pairs are permanently unlocked, not "temp"
    if (_isFreeDefaultPair(candidateBase, candidateQuote)) return false;
    return widget.controller.tempUnlockedCodes.contains(canonical);
  }

  bool _isSameAsFixed(String code) => code == _fixedSide;

  static const _freeDefaults = {'USD', 'EUR'};

  bool _isFreeDefaultCurrency(String code) => _freeDefaults.contains(code);

  bool _isFreeDefaultPair(String a, String b) {
    final sorted = [a, b]..sort();
    return sorted[0] == 'EUR' && sorted[1] == 'USD';
  }

  Future<void> _showLockedAction(BuildContext context, String code) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.card,
      builder: (_) => SafeArea(
        top: false,
        child: LockedPairActionSheet(
          onWatchAd: () => Navigator.of(context).pop('watch_ad'),
          onBuyForever: () {
            Navigator.of(context).pop('buy_forever');
          },
        ),
      ),
    );

    if (!context.mounted || choice == null) return;

    if (choice == 'buy_forever') {
      final granted = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => IapPurchasePlayer(
            controller: widget.controller,
            product: ProductType.chartsPro,
            onResult: (success) => Navigator.of(context).pop(success),
          ),
        ),
      );

      if (granted == true && context.mounted) {
        Navigator.of(context).pop(code);
      }
      return;
    }

    final adBase = widget.selectingBase ? code : widget.baseCurrency;
    final adQuote = widget.selectingBase ? widget.quoteCurrency : code;

    final granted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => RewardedAdPlayer(
          controller: widget.controller,
          base: adBase,
          quote: adQuote,
          onResult: (success) => Navigator.of(context).pop(success),
        ),
      ),
    );

    if (granted == true && context.mounted) {
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .84,
      minChildSize: .42,
      maxChildSize: .92,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            children: <Widget>[
              CurrencyPickerHeader(title: widget.title),
              const SizedBox(height: 12),
              CurrencyPickerSearchField(
                onChanged: (value) =>
                    setState(() => _query = value.trim().toUpperCase()),
              ),
              const SizedBox(height: 12),
              if (widget.controller.adsEnabled) ...[
                const AdBannerPlaceholder(),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: _buildCurrencyList(scrollController: scrollController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matches(SupportedCurrency currency) {
    if (_query.isEmpty) return true;
    final code = currency.code.toUpperCase();
    final name = currency.name.toUpperCase();
    return code.contains(_query) || name.contains(_query);
  }

  Widget _buildCurrencyList({required ScrollController scrollController}) {
    final currencies = supportedCurrencies.where(_matches).toList();
    return ListView.separated(
      controller: scrollController,
      itemCount: currencies.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: AppTheme.border.withValues(alpha: .15)),
      itemBuilder: (context, index) {
        final currency = currencies[index];
        final isSelected = currency.code == widget.selectedCode;
        final isFixed = _isSameAsFixed(currency.code);
        final unlocked = _isUnlocked(currency.code);
        final tempUnlocked = _isTempUnlocked(currency.code);
        return _CurrencyTile(
          symbol: currency.symbol,
          code: currency.code,
          name: currency.name,
          isSelected: isSelected,
          isFixed: isFixed,
          unlocked: unlocked,
          tempUnlocked: tempUnlocked,
          onTap: isFixed
              ? null
              : unlocked
              ? () => Navigator.of(context).pop(currency.code)
              : () => _showLockedAction(context, currency.code),
        );
      },
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.symbol,
    required this.code,
    required this.name,
    required this.isSelected,
    required this.isFixed,
    required this.unlocked,
    required this.tempUnlocked,
    required this.onTap,
  });

  final String symbol;
  final String code;
  final String name;
  final bool isSelected;
  final bool isFixed;
  final bool unlocked;
  final bool tempUnlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !unlocked && !isFixed;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: locked ? .45 : 1,
              child: CurrencyFlagIcon(code: code, symbol: symbol, radius: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: locked ? AppTheme.muted : AppTheme.text,
                    ),
                  ),
                  Text(
                    locked
                        ? 'Tap to unlock'
                        : tempUnlocked
                        ? 'Unlocked · 24h remaining'
                        : isFixed
                        ? 'Current $code'
                        : name,
                    style: TextStyle(
                      fontSize: 12,
                      color: tempUnlocked
                          ? AppTheme.primary.withValues(alpha: .7)
                          : locked
                          ? AppTheme.muted
                          : isFixed
                          ? AppTheme.primary.withValues(alpha: .5)
                          : AppTheme.subtle,
                    ),
                  ),
                ],
              ),
            ),
            if (isFixed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: .15),
                  ),
                ),
                child: Text(
                  'Current',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary.withValues(alpha: .5),
                  ),
                ),
              )
            else if (tempUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: .3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.schedule, size: 13, color: AppTheme.primary),
                    const SizedBox(width: 3),
                    Text(
                      '24h',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.check_circle,
                        size: 13,
                        color: AppTheme.primary,
                      ),
                    ],
                  ],
                ),
              )
            else if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primary)
            else if (unlocked)
              Icon(Icons.chevron_right, color: AppTheme.subtle)
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.container,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.border.withValues(alpha: .4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.lock_outline, size: 13, color: AppTheme.muted),
                    const SizedBox(width: 3),
                    Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
