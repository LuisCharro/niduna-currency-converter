import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../core/ads/ad_banner_widget.dart';
import '../../../core/monetization/models/temporary_unlock.dart';
import '../../../core/monetization/monetization_controller.dart';
import '../../../core/monetization/purchase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/sectioned_currency_picker.dart';
import '../../settings/widgets/iap_purchase_player.dart';
import 'chart_currency_tile.dart';
import 'locked_pair_action_sheet.dart';
import 'rewarded_ad_player.dart';

class ChartCurrencyPickerSheet extends StatefulWidget {
  const ChartCurrencyPickerSheet({
    required this.title,
    required this.selectedCode,
    required this.allowCryptoCharts,
    required this.controller,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.selectingBase,
    super.key,
  });

  final String title;
  final String selectedCode;
  final bool allowCryptoCharts;
  final MonetizationController controller;
  final String baseCurrency;
  final String quoteCurrency;
  final bool selectingBase;

  @override
  State<ChartCurrencyPickerSheet> createState() =>
      _ChartCurrencyPickerSheetState();
}

class _ChartCurrencyPickerSheetState extends State<ChartCurrencyPickerSheet> {
  String get _fixedSide =>
      widget.selectingBase ? widget.quoteCurrency : widget.baseCurrency;

  bool _isUnlocked(String code) {
    if (code == _fixedSide) return true;
    if (_isFreeDefaultCurrency(code)) return true;
    final candidateBase = widget.selectingBase ? code : widget.baseCurrency;
    final candidateQuote = widget.selectingBase ? widget.quoteCurrency : code;
    return widget.controller.isChartPairUnlocked(candidateBase, candidateQuote);
  }

  bool _isTempUnlocked(String code) {
    if (code == _fixedSide) return false;
    if (_isFreeDefaultCurrency(code)) return false;
    final candidateBase = widget.selectingBase ? code : widget.baseCurrency;
    final candidateQuote = widget.selectingBase ? widget.quoteCurrency : code;
    final canonical = TemporaryUnlock.canonicalKey(
      candidateBase,
      candidateQuote,
    );
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
      backgroundColor: AppColors.of(context).card,
      builder: (_) => SafeArea(
        top: false,
        child: LockedPairActionSheet(
          canWatchAd: widget.controller.canOfferRewardedChartUnlock,
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
    final currencies = allSupportedCurrencies
        .where(
          (c) => widget.allowCryptoCharts || !isCryptoCurrency(c.code),
        )
        .toList();

    return SectionedCurrencyPicker(
      title: widget.title,
      subtitle: chartPairSubtitle(
        context,
        widget.baseCurrency,
        widget.quoteCurrency,
      ),
      currencies: currencies,
      headerWidget: widget.controller.adsEnabled
          ? const AdBannerWidget()
          : null,
      tileBuilder: (context, currency) {
        final isSelected = currency.code == widget.selectedCode;
        final isFixed = _isSameAsFixed(currency.code);
        final unlocked = _isUnlocked(currency.code);
        final tempUnlocked = _isTempUnlocked(currency.code);
        return ChartCurrencyTile(
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
