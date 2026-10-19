import 'package:flutter/material.dart';
import 'widgets/chart_orientation_icon.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../l10n/app_localizations_safe.dart';
import '../../core/ads/ad_banner_widget.dart';
import '../../core/monetization/monetization_controller.dart';
import '../../core/monetization/models/temporary_unlock.dart';
import '../../core/theme/app_colors.dart';
import 'presentation/chart_viewer_session.dart';
import 'presentation/charts_controller.dart';
import 'widgets/chart_pair_strip.dart';
import 'widgets/charts_chart_section.dart';
import 'widgets/range_selector.dart';

class ChartsLandscapeScreen extends StatefulWidget {
  const ChartsLandscapeScreen({
    required this.controller,
    required this.monetization,
    required this.session,
    super.key,
  });
  final ChartsController controller;
  final MonetizationController monetization;
  final ChartViewerSession session;

  @override
  State<ChartsLandscapeScreen> createState() => _ChartsLandscapeScreenState();
}

class _ChartsLandscapeScreenState extends State<ChartsLandscapeScreen>
    with WidgetsBindingObserver {
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.isCurrentOf(context) ?? true;
    if (current && !_isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isCurrent) widget.session.landscape();
      });
    }
    _isCurrent = current;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isCurrent) {
      widget.session.landscape();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('charts_landscape_viewer'),
      backgroundColor: AppColors.of(context).bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            widget.controller,
            widget.monetization,
          ]),
          builder: (context, _) {
            final state = widget.controller.state;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RangeSelector(
                        selected: state.range,
                        onChanged: widget.controller.setRange,
                        includesCrypto: state.includesCrypto,
                      ),
                    ),
                    IconButton(
                      key: const Key('charts_collapse'),
                      iconSize: 30,
                      tooltip: l10n(context).collapseChartTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const ChartOrientationIcon(targetLandscape: false),
                    ),
                  ],
                ),
                Expanded(
                  child: ChartsChartSection(
                    state: state,
                    onRangeChanged: widget.controller.setRange,
                    onRetry: widget.controller.load,
                    swapVersion: 0,
                    lastPairKey: '',
                    onSwapSettled: (_) {},
                    compact: true,
                    showRangeSelector: false,
                    compactDetails: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final pairs = ChartPairStrip(
                        base: state.base,
                        quote: state.quote,
                        allowCryptoCharts: widget.controller.allowCryptoCharts,
                        onPairChanged: widget.controller.setPair,
                        onSwap: widget.controller.swapPair,
                        controller: widget.monetization,
                        compact: true,
                        dense: true,
                      );
                      if (!widget.monetization.adsEnabled) {
                        return pairs;
                      }
                      const banner = SizedBox(
                        width: 320,
                        height: 50,
                        child: AdBannerWidget(fixedSize: AdSize.banner),
                      );
                      final textScale =
                          MediaQuery.textScalerOf(context).scale(15) / 15;
                      final temporary = widget.monetization.tempUnlockedCodes
                          .contains(
                            TemporaryUnlock.canonicalKey(
                              state.base,
                              state.quote,
                            ),
                          );
                      final controlsWidth = _controlsWidth(
                        context,
                        [state.base, state.quote],
                        temporary,
                        textScale,
                      );
                      if (constraints.maxWidth >= controlsWidth + 336) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: pairs),
                            const SizedBox(width: 16),
                            banner,
                          ],
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [pairs, const SizedBox(height: 4), banner],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _controlsWidth(
    BuildContext context,
    List<String> codes,
    bool temporary,
    double scale,
  ) {
    var codeWidth = 0.0;
    for (final code in codes) {
      final painter = TextPainter(
        text: TextSpan(
          text: code,
          style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
          ),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (painter.width > codeWidth) codeWidth = painter.width;
      painter.dispose();
    }
    // Swap/gaps plus two equal pills: flag, padding, code and trailing indicator.
    return 56 + 2 * (codeWidth + 57 + (temporary ? 20 * scale : 0));
  }
}
