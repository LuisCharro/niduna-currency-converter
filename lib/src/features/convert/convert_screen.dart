import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import 'data/frankfurter_latest_rates_client.dart';
import 'data/latest_rates_cache.dart';
import 'data/latest_rates_repository.dart';
import 'presentation/convert_controller.dart';
import 'widgets/ad_banner_placeholder.dart';
import 'widgets/convert_content.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({this.repository, super.key});

  final ConvertRatesRepository? repository;

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  late final ConvertController _controller = ConvertController(
    repository:
        widget.repository ??
        LatestRatesRepository(
          client: FrankfurterLatestRatesClient(),
          cache: LatestRatesCache(SharedPreferencesAsync()),
        ),
  );

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bg,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => ConvertContent(
                  state: _controller.state,
                  onRefresh: _controller.refresh,
                  onAmountChanged: _controller.setAmountText,
                  onSelectBase: _controller.setBase,
                  onToggleCode: _controller.toggleCode,
                ),
              ),
            ),
            const AdBannerPlaceholder(),
          ],
        ),
      ),
    );
  }
}
