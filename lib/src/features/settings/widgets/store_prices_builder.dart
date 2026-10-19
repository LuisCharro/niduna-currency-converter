import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/monetization/monetization_controller.dart';
import '../../../core/monetization/purchase_service.dart';

typedef StorePricesWidgetBuilder =
    Widget Function(BuildContext context, Map<ProductType, String> prices);

class StorePricesBuilder extends StatefulWidget {
  const StorePricesBuilder({
    required this.controller,
    required this.builder,
    super.key,
  });

  final MonetizationController controller;
  final StorePricesWidgetBuilder builder;

  @override
  State<StorePricesBuilder> createState() => _StorePricesBuilderState();
}

class _StorePricesBuilderState extends State<StorePricesBuilder>
    with WidgetsBindingObserver {
  Map<ProductType, String> _prices = const {};
  int _requestRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshPrices());
  }

  @override
  void didUpdateWidget(covariant StorePricesBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      unawaited(_refreshPrices());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refreshPrices());
  }

  Future<void> _refreshPrices() async {
    final revision = ++_requestRevision;
    final controller = widget.controller;
    if (_prices.isNotEmpty) setState(() => _prices = const {});

    Map<ProductType, String> prices;
    try {
      prices = await controller.fetchLocalizedPrices();
    } catch (_) {
      prices = const {};
    }

    if (!mounted || revision != _requestRevision) return;
    if (!identical(controller, widget.controller)) return;
    setState(() => _prices = Map<ProductType, String>.unmodifiable(prices));
  }

  @override
  void dispose() {
    ++_requestRevision;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _prices);
}
