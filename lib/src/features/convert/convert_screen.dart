import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'data/demo_quotes.dart';
import 'widgets/ad_banner_placeholder.dart';
import 'widgets/amount_card.dart';
import 'widgets/convert_header.dart';
import 'widgets/currency_rate_row.dart';

class ConvertScreen extends StatelessWidget {
  const ConvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.bg,
      child: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverToBoxAdapter(child: ConvertHeader()),
            const SliverToBoxAdapter(child: AmountCard()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList.separated(
                itemBuilder: (context, index) =>
                    CurrencyRateRow(quote: demoQuotes[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: demoQuotes.length,
              ),
            ),
            const SliverToBoxAdapter(child: AdBannerPlaceholder()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}
