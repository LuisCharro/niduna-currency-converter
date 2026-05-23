import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/purchase_service.dart';
import '../../shared/widgets/bottom_tab_frame.dart';
import '../../shared/widgets/canvas_background.dart';
import '../convert/widgets/ad_support_shelf.dart';
import '../settings/widgets/iap_purchase_player.dart';
import 'presentation/charts_controller.dart';
import 'widgets/charts_tab_body.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({
    required this.controller,
    required this.monetization,
    super.key,
  });

  final ChartsController controller;
  final MonetizationController monetization;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  void _showRemoveAds(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => IapPurchasePlayer(
          controller: widget.monetization,
          product: ProductType.removeAds,
          onResult: (success) => Navigator.of(context).pop(success),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CanvasBackground(
        child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: widget.monetization,
            builder: (context, _) => BottomTabFrame(
              body: ChartsTabBody(
                controller: widget.controller,
                monetization: widget.monetization,
              ),
              footer: widget.monetization.adsEnabled
                  ? AdSupportShelf(onRemoveAds: () => _showRemoveAds(context))
                  : null,
            ),
          );
        },
        ),
      ),
    );
  }
}
