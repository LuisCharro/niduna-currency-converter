import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/share/share_rate_card.dart';
import '../../shared/widgets/bottom_tab_frame.dart';
import '../../shared/widgets/canvas_background.dart';
import '../../../l10n/app_localizations_safe.dart';
import 'data/convert_row_hint_store.dart';
import 'presentation/convert_controller.dart';
import 'presentation/rate_card_data_mapper.dart';
import 'widgets/ad_support_shelf.dart';
import 'widgets/convert_content.dart';

class ConvertScreen extends StatelessWidget {
  const ConvertScreen({
    required this.controller,
    required this.monetization,
    required this.onNavigateToSettings,
    this.hintStore,
    super.key,
  });

  final ConvertController controller;
  final MonetizationController monetization;
  final VoidCallback onNavigateToSettings;
  final ConvertRowHintStore? hintStore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CanvasBackground(
        child: ListenableBuilder(
          listenable: monetization,
          builder: (context, _) => BottomTabFrame(
            body: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => ConvertContent(
                state: controller.state,
                decimalPlaces: controller.decimalPlaces,
                hintStore: hintStore,
                onRefresh: controller.refresh,
                onAmountChanged: controller.setAmountText,
                onSelectBase: controller.setBase,
                onToggleCode: (code) => _toggleCurrency(context, code),
                onToggleFavorite: controller.tryToggleFavorite,
                onMore: onNavigateToSettings,
                onShare: controller.state.hasQuotes
                    ? () => unawaited(
                        shareRateCard(
                          context,
                          rateCardDataFromState(controller.state),
                        ),
                      )
                    : null,
                maxFavoritesReached: controller.maxFavoritesReached,
              ),
            ),
            footer: monetization.adsEnabled ? const AdSupportShelf() : null,
          ),
        ),
      ),
    );
  }

  void _toggleCurrency(BuildContext context, String code) {
    final removing = controller.state.selectedCodes.contains(code);
    final index = controller.state.savedCodes.indexOf(code);
    controller.toggleCode(code);
    if (!removing || controller.state.selectedCodes.contains(code)) return;
    final loc = l10n(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(loc.currencyRemoved(code)),
          action: SnackBarAction(
            label: loc.btnUndo,
            onPressed: () => controller.restoreCode(code, index),
          ),
        ),
      );
  }
}
