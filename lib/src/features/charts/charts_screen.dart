import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../shared/widgets/bottom_tab_frame.dart';
import '../../shared/widgets/canvas_background.dart';
import '../convert/widgets/ad_support_shelf.dart';
import 'presentation/charts_controller.dart';
import 'presentation/chart_viewer_session.dart';
import 'charts_landscape_screen.dart';
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
  final _viewer = ChartViewerSession();

  @override
  void dispose() {
    _viewer.dispose();
    super.dispose();
  }

  void _expand() {
    _viewer.open(
      context,
      (_) => ChartsLandscapeScreen(
        controller: widget.controller,
        monetization: widget.monetization,
        session: _viewer,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewer,
      builder: (context, _) {
        // The covered portrait composition must not lay out in a short viewport.
        if (_viewer.active) return const SizedBox.expand();
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
                      onExpand:
                          !kIsWeb &&
                              defaultTargetPlatform == TargetPlatform.android
                          ? _expand
                          : null,
                    ),
                    footer: widget.monetization.adsEnabled
                        ? const AdSupportShelf()
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
